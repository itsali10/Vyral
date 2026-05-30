import {
  BadRequestException,
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectDataSource, InjectRepository } from '@nestjs/typeorm';
import { DataSource, ILike, In, IsNull, QueryFailedError, Repository } from 'typeorm';
import { ensureSettingsTablesExist } from '../database/ensure-settings-tables';
import { User } from '../entities/user.entity';
import { UserSettings } from '../entities/user-settings.entity';
import { UserBlock } from '../entities/user-block.entity';
import { Post } from '../entities/post.entity';
import { Reel } from '../entities/reel.entity';
import { SavedPost } from '../entities/saved-post.entity';
import { SavedCollection } from '../entities/saved-collection.entity';
import { Follow } from '../entities/follow.entity';
import { PostLike } from '../entities/post-like.entity';
import { Comment } from '../entities/comment.entity';
import { FollowStatus } from '../entities/enums';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UpdateSettingsDto } from './dto/update-settings.dto';
import { CreateCollectionDto } from './dto/create-collection.dto';
import { toFeedPost, toPublicUser } from '../common/mappers/post.mapper';
import { toSettingsView } from '../common/mappers/settings.mapper';
import { SupabaseService } from '../supabase/supabase.service';

@Injectable()
export class UsersService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    @InjectRepository(Post)
    private readonly postRepo: Repository<Post>,
    @InjectRepository(Reel)
    private readonly reelRepo: Repository<Reel>,
    @InjectRepository(SavedPost)
    private readonly savedPostRepo: Repository<SavedPost>,
    @InjectRepository(SavedCollection)
    private readonly collectionRepo: Repository<SavedCollection>,
    @InjectRepository(Follow)
    private readonly followRepo: Repository<Follow>,
    @InjectRepository(PostLike)
    private readonly likeRepo: Repository<PostLike>,
    @InjectRepository(Comment)
    private readonly commentRepo: Repository<Comment>,
    @InjectRepository(UserSettings)
    private readonly settingsRepo: Repository<UserSettings>,
    @InjectRepository(UserBlock)
    private readonly blockRepo: Repository<UserBlock>,
    @InjectDataSource()
    private readonly dataSource: DataSource,
    private readonly supabase: SupabaseService,
  ) {}

  private static _settingsTablesReady = false;

  private async ensureSettingsTables() {
    if (UsersService._settingsTablesReady) return;
    await ensureSettingsTablesExist(this.dataSource);
    UsersService._settingsTablesReady = true;
  }

  async ensureSettings(userId: string) {
    await this.ensureSettingsTables();
    try {
      let settings = await this.settingsRepo.findOne({ where: { userId } });
      if (!settings) {
        settings = await this.settingsRepo.save(
          this.settingsRepo.create({ userId }),
        );
      }
      return settings;
    } catch (error) {
      if (this.isMissingSettingsTable(error)) {
        UsersService._settingsTablesReady = false;
        await ensureSettingsTablesExist(this.dataSource);
        UsersService._settingsTablesReady = true;
        return this.ensureSettings(userId);
      }
      throw error;
    }
  }

  private isMissingSettingsTable(error: unknown): boolean {
    return (
      error instanceof QueryFailedError &&
      (error as QueryFailedError & { driverError?: { code?: string } })
        .driverError?.code === '42P01'
    );
  }

  async getMe(userId: string) {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    const stats = await this.getStats(userId);
    const settings = await this.ensureSettings(userId);
    return {
      ...toPublicUser(user, stats),
      email: user.email,
      settings: toSettingsView(settings),
    };
  }

  async getSettings(userId: string) {
    const settings = await this.ensureSettings(userId);
    return toSettingsView(settings);
  }

  async updateSettings(userId: string, dto: UpdateSettingsDto) {
    const settings = await this.ensureSettings(userId);
    if (dto.mutedWords) {
      dto.mutedWords = dto.mutedWords
        .map((w) => w.trim().toLowerCase())
        .filter((w) => w.length > 0);
    }
    Object.assign(settings, dto);
    const saved = await this.settingsRepo.save(settings);
    return toSettingsView(saved);
  }

  async getBlockedUsers(userId: string) {
    const blocks = await this.blockRepo.find({
      where: { blockerId: userId },
      relations: { blocked: true },
      order: { createdAt: 'DESC' },
    });
    return {
      items: blocks.map((b) => ({
        id: b.blocked.id,
        username: b.blocked.username,
        displayUsername: `@${b.blocked.username}`,
        fullName: b.blocked.fullName,
        avatarUrl: b.blocked.avatarUrl,
        blockedAt: b.createdAt,
      })),
    };
  }

  async getBlockedUserIds(userId: string): Promise<string[]> {
    const blocks = await this.blockRepo.find({
      where: { blockerId: userId },
      select: { blockedId: true },
    });
    return blocks.map((b) => b.blockedId);
  }

  async blockUser(blockerId: string, blockedId: string) {
    if (blockerId === blockedId) {
      throw new BadRequestException('You cannot block yourself');
    }
    const target = await this.userRepo.findOne({ where: { id: blockedId } });
    if (!target) throw new NotFoundException('User not found');

    const existing = await this.blockRepo.findOne({
      where: { blockerId, blockedId },
    });
    if (existing) {
      return { message: 'User already blocked' };
    }

    await this.blockRepo.save(
      this.blockRepo.create({ blockerId, blockedId }),
    );
    await this.followRepo.delete({ followerId: blockerId, followingId: blockedId });
    await this.followRepo.delete({ followerId: blockedId, followingId: blockerId });

    return { message: 'User blocked' };
  }

  async unblockUser(blockerId: string, blockedId: string) {
    const block = await this.blockRepo.findOne({
      where: { blockerId, blockedId },
    });
    if (!block) throw new NotFoundException('Block not found');
    await this.blockRepo.remove(block);
    return { message: 'User unblocked' };
  }

  async searchUsers(requesterId: string, query: string, limit = 10) {
    const q = query.trim().replace(/^@/, '').toLowerCase();
    if (q.length < 2) {
      throw new BadRequestException('Search query must be at least 2 characters');
    }
    const users = await this.userRepo.find({
      where: [{ username: ILike(`%${q}%`) }, { fullName: ILike(`%${q}%`) }],
      take: limit,
    });
    const blockedIds = new Set(await this.getBlockedUserIds(requesterId));
    return {
      items: users
        .filter((u) => u.id !== requesterId && !blockedIds.has(u.id))
        .map((u) => ({
          id: u.id,
          username: u.username,
          displayUsername: `@${u.username}`,
          fullName: u.fullName,
          avatarUrl: u.avatarUrl,
        })),
    };
  }

  async updateMe(userId: string, dto: UpdateProfileDto) {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');

    if (dto.username && dto.username !== user.username) {
      const taken = await this.userRepo.findOne({
        where: { username: dto.username },
      });
      if (taken) throw new ConflictException('Username already taken');
    }

    Object.assign(user, dto);
    await this.userRepo.save(user);
    const stats = await this.getStats(userId);
    return toPublicUser(user, stats);
  }

  async deleteMe(userId: string) {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    await this.supabase.getAdminClient().auth.admin.deleteUser(userId);
    await this.userRepo.remove(user);
    return { message: 'Account deleted' };
  }

  async getProfile(requesterId: string, targetId: string) {
    const user = await this.userRepo.findOne({ where: { id: targetId } });
    if (!user) throw new NotFoundException('User not found');

    if (user.isPrivate && requesterId !== targetId) {
      const following = await this.followRepo.findOne({
        where: {
          followerId: requesterId,
          followingId: targetId,
          status: FollowStatus.ACCEPTED,
        },
      });
      if (!following) {
        const stats = await this.getStats(targetId);
        const isFollowing = !!(await this.followRepo.findOne({
          where: { followerId: requesterId, followingId: targetId },
        }));
        return {
          ...toPublicUser(user, stats),
          isPrivate: true,
          bio: null,
          isFollowing,
        };
      }
    }

    const stats = await this.getStats(targetId);
    const isFollowing =
      requesterId !== targetId &&
      !!(await this.followRepo.findOne({
        where: { followerId: requesterId, followingId: targetId },
      }));
    const settings = await this.settingsRepo.findOne({ where: { userId: targetId } });
    return {
      ...toPublicUser(user, stats),
      isFollowing,
      showLikesPublicly: settings?.showLikesPublicly ?? true,
    };
  }

  async getUserPosts(
    requesterId: string,
    targetId: string,
    page = 1,
    limit = 12,
  ) {
    await this.assertUserExists(targetId);
    const posts = await this.postRepo
      .createQueryBuilder('post')
      .leftJoinAndSelect('post.author', 'author')
      .where('post.authorId = :targetId', { targetId })
      .orderBy('post.pinnedAt', 'DESC', 'NULLS LAST')
      .addOrderBy('post.createdAt', 'DESC')
      .take(limit)
      .skip((page - 1) * limit)
      .getMany();
    return this.mapPostsForViewer(posts, requesterId);
  }

  async getUserPins(targetId: string, page = 1, limit = 12) {
    await this.assertUserExists(targetId);
    const posts = await this.postRepo.find({
      where: { authorId: targetId },
      order: { createdAt: 'DESC' },
      take: limit,
      skip: (page - 1) * limit,
      select: {
        id: true,
        mediaUrls: true,
        type: true,
        caption: true,
        createdAt: true,
      },
    });
    return posts.map((p) => ({
      id: p.id,
      mediaUrl: p.mediaUrls[0] ?? null,
      caption: p.caption,
      createdAt: p.createdAt,
    }));
  }

  async getUserReels(
    _requesterId: string,
    targetId: string,
    page = 1,
    limit = 12,
  ) {
    await this.assertUserExists(targetId);
    return this.reelRepo.find({
      where: { authorId: targetId },
      order: { createdAt: 'DESC' },
      take: limit,
      skip: (page - 1) * limit,
      select: {
        id: true,
        videoUrl: true,
        likesCount: true,
        commentsCount: true,
        viewsCount: true,
        createdAt: true,
      },
    });
  }

  async getSavedCollections(userId: string) {
    const defaultCollection = await this.ensureDefaultCollection(userId);
    await this.savedPostRepo.update(
      { userId, collectionId: IsNull() },
      { collectionId: defaultCollection.id },
    );
    const collections = await this.collectionRepo.find({
      where: { userId },
      order: { createdAt: 'ASC' },
    });
    const result = await Promise.all(
      collections.map(async (c) => {
        const postCount = await this.savedPostRepo.count({
          where: { userId, collectionId: c.id },
        });
        return {
          id: c.id,
          name: c.name,
          postCount: String(postCount),
        };
      }),
    );
    return { collections: result };
  }

  async createCollection(userId: string, dto: CreateCollectionDto) {
    const collection = this.collectionRepo.create({
      userId,
      name: dto.name,
    });
    const saved = await this.collectionRepo.save(collection);
    return { id: saved.id, name: saved.name, postCount: '0' };
  }

  async getCollectionPosts(
    userId: string,
    collectionId: string,
    page = 1,
    limit = 12,
  ) {
    const collection = await this.collectionRepo.findOne({
      where: { id: collectionId, userId },
    });
    if (!collection) throw new NotFoundException('Collection not found');

    const saves = await this.savedPostRepo.find({
      where: { userId, collectionId },
      relations: { post: { author: true } },
      order: { savedAt: 'DESC' },
      take: limit,
      skip: (page - 1) * limit,
    });
    const posts = saves.map((s) => s.post).filter(Boolean);
    return {
      collection: { id: collection.id, name: collection.name },
      items: await this.mapPostsForViewer(posts, userId),
    };
  }

  async getSavedPosts(userId: string, page = 1, limit = 12) {
    const defaultCollection = await this.ensureDefaultCollection(userId);
    return this.getCollectionPosts(userId, defaultCollection.id, page, limit);
  }

  async getLikedPosts(requesterId: string, targetId: string, page = 1, limit = 12) {
    if (requesterId !== targetId) {
      const settings = await this.settingsRepo.findOne({ where: { userId: targetId } });
      if (!settings?.showLikesPublicly) {
        return { items: [] };
      }
    }
    const likes = await this.likeRepo.find({
      where: { userId: targetId },
      relations: { post: { author: true } },
      order: { createdAt: 'DESC' },
      take: limit,
      skip: (page - 1) * limit,
    });
    const posts = likes.map((l) => l.post).filter(Boolean);
    return { items: await this.mapPostsForViewer(posts, requesterId) };
  }

  private async ensureDefaultCollection(userId: string) {
    let collection = await this.collectionRepo.findOne({
      where: { userId, name: 'All saved' },
    });
    if (!collection) {
      collection = await this.collectionRepo.save(
        this.collectionRepo.create({ userId, name: 'All saved' }),
      );
    }
    return collection;
  }

  private async getStats(userId: string) {
    const [postsCount, followersCount, followingCount] = await Promise.all([
      this.postRepo.count({ where: { authorId: userId } }),
      this.followRepo.count({
        where: { followingId: userId, status: FollowStatus.ACCEPTED },
      }),
      this.followRepo.count({
        where: { followerId: userId, status: FollowStatus.ACCEPTED },
      }),
    ]);
    return { postsCount, followersCount, followingCount };
  }

  async mapPostsForViewer(posts: Post[], viewerId: string) {
    if (posts.length === 0) return [];
    const ids = posts.map((p) => p.id);
    const authorIds = [...new Set(posts.map((p) => p.authorId))];
    const likes = await this.likeRepo.find({
      where: { userId: viewerId, postId: In(ids) },
    });
    const saves = await this.savedPostRepo.find({
      where: { userId: viewerId, postId: In(ids) },
    });
    const authorSettings = await this.settingsRepo.find({
      where: { userId: In(authorIds) },
    });
    const settingsByAuthor = new Map(
      authorSettings.map((s) => [s.userId, s]),
    );
    const likedSet = new Set(likes.map((l) => l.postId));
    const savedSet = new Set(saves.map((s) => s.postId));
    const commentRows = await this.commentRepo
      .createQueryBuilder('c')
      .select('c.postId', 'postId')
      .addSelect('COUNT(c.id)', 'cnt')
      .where('c.postId IN (:...ids)', { ids })
      .groupBy('c.postId')
      .getRawMany();
    const commentCountByPost = new Map<string, number>();
    for (const row of commentRows) {
      const postId = (row.postId ?? row.postid ?? row.c_postId) as
        | string
        | undefined;
      const cnt = Number(row.cnt ?? row.count ?? 0);
      if (postId) commentCountByPost.set(postId, cnt);
    }
    return posts.map((post) => {
      const authorPrefs = settingsByAuthor.get(post.authorId);
      const showLikesCount =
        viewerId === post.authorId ||
        (authorPrefs?.showLikesPublicly ?? true);
      return toFeedPost(post, {
        isLiked: likedSet.has(post.id),
        isSaved: savedSet.has(post.id),
        showLikesCount,
        commentsCount: commentCountByPost.get(post.id) ?? 0,
      });
    });
  }

  private async assertUserExists(userId: string) {
    const exists = await this.userRepo.existsBy({ id: userId });
    if (!exists) throw new NotFoundException('User not found');
  }
}
