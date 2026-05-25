import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, Repository } from 'typeorm';
import { Reel } from '../entities/reel.entity';
import { Follow } from '../entities/follow.entity';
import { FollowStatus } from '../entities/enums';
import { CreateReelDto } from './dto/create-reel.dto';

@Injectable()
export class ReelsService {
  constructor(
    @InjectRepository(Reel)
    private readonly reelRepo: Repository<Reel>,
    @InjectRepository(Follow)
    private readonly followRepo: Repository<Follow>,
  ) {}

  async create(userId: string, dto: CreateReelDto) {
    const reel = this.reelRepo.create({
      authorId: userId,
      videoUrl: dto.videoUrl,
      caption: dto.caption ?? undefined,
      audioTrack: dto.audioTrack ?? undefined,
      duration: dto.duration,
      hashtags: dto.hashtags ?? [],
    });
    return this.reelRepo.save(reel);
  }

  async findOne(id: string) {
    const reel = await this.reelRepo.findOne({
      where: { id },
      relations: { author: true },
    });
    if (!reel) throw new NotFoundException('Reel not found');

    // Increment view count
    await this.reelRepo.increment({ id }, 'viewsCount', 1);
    reel.viewsCount += 1;

    return reel;
  }

  async getFeed(userId: string, page = 1, limit = 10) {
    const follows = await this.followRepo.find({
      where: { followerId: userId, status: FollowStatus.ACCEPTED },
      select: { followingId: true },
    });

    const followedIds = follows.map((f) => f.followingId);

    // Include own reels in feed
    const authorIds = [...followedIds, userId];

    if (authorIds.length === 0) return [];

    return this.reelRepo.find({
      where: { authorId: In(authorIds) },
      relations: { author: true },
      order: { createdAt: 'DESC' },
      take: limit,
      skip: (page - 1) * limit,
    });
  }

  async remove(id: string, userId: string) {
    const reel = await this.reelRepo.findOne({ where: { id } });
    if (!reel) throw new NotFoundException('Reel not found');
    if (reel.authorId !== userId) {
      throw new ForbiddenException('You can only delete your own reels');
    }
    await this.reelRepo.remove(reel);
    return { message: 'Reel deleted' };
  }
}
