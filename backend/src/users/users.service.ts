import {
  ConflictException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { User } from '../entities/user.entity';
import { Post } from '../entities/post.entity';
import { Reel } from '../entities/reel.entity';
import { SavedPost } from '../entities/saved-post.entity';
import { UpdateProfileDto } from './dto/update-profile.dto';

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
  ) {}

  async getMe(userId: string) {
    const user = await this.userRepo.findOne({ where: { id: userId } });
    if (!user) throw new NotFoundException('User not found');
    return user;
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
    return this.userRepo.save(user);
  }

  async getProfile(requesterId: string, targetId: string) {
    const user = await this.userRepo.findOne({ where: { id: targetId } });
    if (!user) throw new NotFoundException('User not found');

    // For private accounts, only return basic info to non-followers
    // (follow check will be added when Follow module is implemented)
    if (user.isPrivate && requesterId !== targetId) {
      return {
        id: user.id,
        username: user.username,
        fullName: user.fullName,
        avatarUrl: user.avatarUrl,
        isPrivate: true,
        isVerified: user.isVerified,
        createdAt: user.createdAt,
      };
    }

    return user;
  }

  async getUserPosts(
    requesterId: string,
    targetId: string,
    page = 1,
    limit = 12,
  ) {
    await this.assertUserExists(targetId);

    return this.postRepo.find({
      where: { authorId: targetId },
      order: { createdAt: 'DESC' },
      take: limit,
      skip: (page - 1) * limit,
      select: {
        id: true,
        mediaUrls: true,
        type: true,
        likesCount: true,
        commentsCount: true,
        createdAt: true,
      },
    });
  }

  async getUserReels(
    requesterId: string,
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

  async getSavedPosts(userId: string, page = 1, limit = 12) {
    const saves = await this.savedPostRepo.find({
      where: { userId },
      relations: { post: { author: true } },
      order: { savedAt: 'DESC' },
      take: limit,
      skip: (page - 1) * limit,
    });

    return saves.map((s) => s.post);
  }

  private async assertUserExists(userId: string) {
    const exists = await this.userRepo.existsBy({ id: userId });
    if (!exists) throw new NotFoundException('User not found');
  }
}
