import {
  BadRequestException,
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { IsNull, Repository } from 'typeorm';
import { Post } from '../entities/post.entity';
import { PostLike } from '../entities/post-like.entity';
import { SavedPost } from '../entities/saved-post.entity';
import { SavedCollection } from '../entities/saved-collection.entity';
import { Comment } from '../entities/comment.entity';
import { Follow } from '../entities/follow.entity';
import { FollowStatus } from '../entities/enums';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { CreateCommentDto } from './dto/create-comment.dto';
import { UsersService } from '../users/users.service';

export type FeedTab = 'for_you' | 'following' | 'trending';

@Injectable()
export class PostsService {
  constructor(
    @InjectRepository(Post)
    private readonly postRepo: Repository<Post>,
    @InjectRepository(PostLike)
    private readonly likeRepo: Repository<PostLike>,
    @InjectRepository(SavedPost)
    private readonly savedRepo: Repository<SavedPost>,
    @InjectRepository(Comment)
    private readonly commentRepo: Repository<Comment>,
    @InjectRepository(Follow)
    private readonly followRepo: Repository<Follow>,
    @InjectRepository(SavedCollection)
    private readonly collectionRepo: Repository<SavedCollection>,
    private readonly usersService: UsersService,
  ) {}

  private async applyFeedFilters(
    posts: Post[],
    viewerId: string,
  ): Promise<Post[]> {
    const settings = await this.usersService.ensureSettings(viewerId);
    const muted = (settings.mutedWords ?? []).map((w) => w.toLowerCase());
    if (muted.length === 0) return posts;
    return posts.filter((post) => {
      const caption = (post.caption ?? '').toLowerCase();
      return !muted.some((word) => caption.includes(word));
    });
  }

  private async excludeBlockedAuthors<T extends { andWhere: (...args: unknown[]) => T }>(
    qb: T,
    viewerId: string,
  ): Promise<T> {
    const blockedIds = await this.usersService.getBlockedUserIds(viewerId);
    if (blockedIds.length > 0) {
      qb.andWhere('post.authorId NOT IN (:...blockedIds)', { blockedIds });
    }
    return qb;
  }

  async create(userId: string, dto: CreatePostDto) {
    const post = this.postRepo.create({
      authorId: userId,
      type: dto.type,
      caption: dto.caption ?? undefined,
      mediaUrls: dto.mediaUrls ?? [],
      hashtags: dto.hashtags ?? [],
      location: dto.location ?? undefined,
    });
    const saved = await this.postRepo.save(post);
    return this.findOneForViewer(saved.id, userId);
  }

  async getFeed(userId: string, tab: FeedTab, page = 1, limit = 20) {
    const qb = this.postRepo
      .createQueryBuilder('post')
      .leftJoinAndSelect('post.author', 'author')
      .orderBy('post.createdAt', 'DESC')
      .take(limit)
      .skip((page - 1) * limit);

    if (tab === 'following') {
      const follows = await this.followRepo.find({
        where: { followerId: userId },
        select: { followingId: true, status: true },
      });
      const followedIds = follows
        .filter((f) => f.status === FollowStatus.ACCEPTED)
        .map((f) => f.followingId);
      if (followedIds.length === 0) {
        return { items: [], page, limit, total: 0 };
      }
      qb.where('post.authorId IN (:...followedIds)', { followedIds });
    } else {
      qb.andWhere('post.authorId != :viewerId', { viewerId: userId });
      if (tab === 'trending') {
        qb.orderBy('post.likesCount', 'DESC').addOrderBy('post.createdAt', 'DESC');
      }
    }

    await this.excludeBlockedAuthors(qb, userId);

    const [rawPosts, total] = await qb.getManyAndCount();
    const posts = await this.applyFeedFilters(rawPosts, userId);
    const items = await this.usersService.mapPostsForViewer(posts, userId);
    return { items, page, limit, total };
  }

  async explore(userId: string, q?: string, category?: string, page = 1, limit = 20) {
    const qb = this.postRepo
      .createQueryBuilder('post')
      .leftJoinAndSelect('post.author', 'author')
      .orderBy('post.createdAt', 'DESC')
      .take(limit)
      .skip((page - 1) * limit);

    const query = q?.trim().toLowerCase();
    if (query) {
      qb.andWhere(
        '(LOWER(post.caption) LIKE :q OR LOWER(author.username) LIKE :q)',
        { q: `%${query}%` },
      );
    }

    const cat = category?.trim().toLowerCase();
    if (cat && cat !== 'all') {
      qb.andWhere('LOWER(post.caption) LIKE :cat', { cat: `%${cat}%` });
    }

    qb.andWhere('post.authorId != :viewerId', { viewerId: userId });
    await this.excludeBlockedAuthors(qb, userId);

    const [rawPosts, total] = await qb.getManyAndCount();
    const posts = await this.applyFeedFilters(rawPosts, userId);
    const items = await this.usersService.mapPostsForViewer(posts, userId);
    return { items, page, limit, total };
  }

  async findOne(id: string) {
    const post = await this.postRepo.findOne({
      where: { id },
      relations: { author: true },
    });
    if (!post) throw new NotFoundException('Post not found');
    return post;
  }

  async findOneForViewer(id: string, viewerId: string) {
    const post = await this.findOne(id);
    const [mapped] = await this.usersService.mapPostsForViewer([post], viewerId);
    return mapped;
  }

  async update(id: string, userId: string, dto: UpdatePostDto) {
    const post = await this.findOne(id);
    this.assertOwner(post.authorId, userId);
    Object.assign(post, dto);
    const saved = await this.postRepo.save(post);
    return this.findOneForViewer(saved.id, userId);
  }

  async remove(id: string, userId: string) {
    const post = await this.findOne(id);
    this.assertOwner(post.authorId, userId);
    await this.postRepo.remove(post);
    return { message: 'Post deleted' };
  }

  async like(postId: string, userId: string) {
    await this.findOne(postId);
    const existing = await this.likeRepo.findOne({
      where: { postId, userId },
    });
    if (!existing) {
      await this.likeRepo.save(this.likeRepo.create({ postId, userId }));
    }
    await this.syncLikesCount(postId);
    return this.findOneForViewer(postId, userId);
  }

  async unlike(postId: string, userId: string) {
    await this.findOne(postId);
    const existing = await this.likeRepo.findOne({
      where: { postId, userId },
    });
    if (existing) {
      await this.likeRepo.remove(existing);
    }
    await this.syncLikesCount(postId);
    return this.findOneForViewer(postId, userId);
  }

  async save(postId: string, userId: string, collectionId?: string) {
    await this.findOne(postId);
    const targetCollectionId =
      collectionId ?? (await this.ensureDefaultCollectionId(userId));
    const existing = await this.savedRepo.findOne({
      where: { postId, userId },
    });
    if (!existing) {
      await this.savedRepo.save(
        this.savedRepo.create({
          postId,
          userId,
          collectionId: targetCollectionId,
        }),
      );
      await this.postRepo.increment({ id: postId }, 'savesCount', 1);
    } else if (!existing.collectionId) {
      existing.collectionId = targetCollectionId;
      await this.savedRepo.save(existing);
    }
    return this.findOneForViewer(postId, userId);
  }

  private async ensureDefaultCollectionId(userId: string) {
    let collection = await this.collectionRepo.findOne({
      where: { userId, name: 'All saved' },
    });
    if (!collection) {
      collection = await this.collectionRepo.save(
        this.collectionRepo.create({ userId, name: 'All saved' }),
      );
    }
    await this.savedRepo.update(
      { userId, collectionId: IsNull() },
      { collectionId: collection.id },
    );
    return collection.id;
  }

  async unsave(postId: string, userId: string) {
    await this.findOne(postId);
    const existing = await this.savedRepo.findOne({
      where: { postId, userId },
    });
    if (existing) {
      await this.savedRepo.remove(existing);
      const count = await this.savedRepo.count({ where: { postId } });
      await this.postRepo.update({ id: postId }, { savesCount: count });
    }
    return this.findOneForViewer(postId, userId);
  }

  private async syncLikesCount(postId: string) {
    const count = await this.likeRepo.count({ where: { postId } });
    await this.postRepo.update({ id: postId }, { likesCount: Math.max(0, count) });
  }

  async getComments(postId: string, page = 1, limit = 20) {
    await this.findOne(postId);
    const [items, total] = await this.commentRepo.findAndCount({
      where: { postId },
      relations: { author: true },
      order: { createdAt: 'DESC' },
      take: limit,
      skip: (page - 1) * limit,
    });
    return {
      items: items.map((c) => ({
        id: c.id,
        text: c.text,
        likesCount: c.likesCount,
        createdAt: c.createdAt,
        author: c.author
          ? {
              id: c.author.id,
              username: `@${c.author.username}`,
              avatarUrl: c.author.avatarUrl,
            }
          : null,
      })),
      page,
      limit,
      total,
    };
  }

  async addComment(postId: string, userId: string, dto: CreateCommentDto) {
    await this.findOne(postId);
    const comment = this.commentRepo.create({
      postId,
      authorId: userId,
      text: dto.text,
    });
    await this.commentRepo.save(comment);
    await this.postRepo.increment({ id: postId }, 'commentsCount', 1);
    return this.findOneForViewer(postId, userId);
  }

  private assertOwner(authorId: string, requesterId: string) {
    if (authorId !== requesterId) {
      throw new ForbiddenException('You can only modify your own posts');
    }
  }
}
