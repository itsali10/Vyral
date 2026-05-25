import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Post } from '../entities/post.entity';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';

@Injectable()
export class PostsService {
  constructor(
    @InjectRepository(Post)
    private readonly postRepo: Repository<Post>,
  ) {}

  async create(userId: string, dto: CreatePostDto) {
    const post = this.postRepo.create({
      authorId: userId,
      type: dto.type,
      caption: dto.caption ?? undefined,
      mediaUrls: dto.mediaUrls ?? [],
      hashtags: dto.hashtags ?? [],
      location: dto.location ?? undefined,
    });
    return this.postRepo.save(post);
  }

  async findOne(id: string) {
    const post = await this.postRepo.findOne({
      where: { id },
      relations: { author: true },
    });
    if (!post) throw new NotFoundException('Post not found');
    return post;
  }

  async update(id: string, userId: string, dto: UpdatePostDto) {
    const post = await this.findOne(id);
    this.assertOwner(post.authorId, userId);
    Object.assign(post, dto);
    return this.postRepo.save(post);
  }

  async remove(id: string, userId: string) {
    const post = await this.findOne(id);
    this.assertOwner(post.authorId, userId);
    await this.postRepo.remove(post);
    return { message: 'Post deleted' };
  }

  private assertOwner(authorId: string, requesterId: string) {
    if (authorId !== requesterId) {
      throw new ForbiddenException('You can only modify your own posts');
    }
  }
}
