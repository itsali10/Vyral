import {
  ForbiddenException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { In, MoreThan, Repository } from 'typeorm';
import { Story } from '../entities/story.entity';
import { StoryView } from '../entities/story-view.entity';
import { Follow } from '../entities/follow.entity';
import { FollowStatus } from '../entities/enums';
import { CreateStoryDto } from './dto/create-story.dto';

@Injectable()
export class StoriesService {
  constructor(
    @InjectRepository(Story)
    private readonly storyRepo: Repository<Story>,
    @InjectRepository(StoryView)
    private readonly storyViewRepo: Repository<StoryView>,
    @InjectRepository(Follow)
    private readonly followRepo: Repository<Follow>,
  ) {}

  async create(userId: string, dto: CreateStoryDto) {
    const expiresAt = new Date();
    expiresAt.setHours(expiresAt.getHours() + 24);

    const story = this.storyRepo.create({
      authorId: userId,
      mediaUrl: dto.mediaUrl,
      caption: dto.caption ?? undefined,
      expiresAt,
    });
    return this.storyRepo.save(story);
  }

  async getFeed(userId: string) {
    const follows = await this.followRepo.find({
      where: { followerId: userId, status: FollowStatus.ACCEPTED },
      select: { followingId: true },
    });

    const followedIds = follows.map((f) => f.followingId);
    const authorIds = [...followedIds, userId];

    const stories = await this.storyRepo.find({
      where: {
        authorId: In(authorIds),
        expiresAt: MoreThan(new Date()),
      },
      relations: { author: true },
      order: { createdAt: 'DESC' },
    });

    // Group stories by author
    const grouped = new Map<string, { author: any; stories: Story[] }>();
    for (const story of stories) {
      if (!grouped.has(story.authorId)) {
        grouped.set(story.authorId, { author: story.author, stories: [] });
      }
      grouped.get(story.authorId)!.stories.push(story);
    }

    return Array.from(grouped.values());
  }

  async getByUser(targetUserId: string) {
    return this.storyRepo.find({
      where: {
        authorId: targetUserId,
        expiresAt: MoreThan(new Date()),
      },
      relations: { author: true, views: true },
      order: { createdAt: 'ASC' },
    });
  }

  async view(storyId: string, viewerId: string) {
    const story = await this.storyRepo.findOne({ where: { id: storyId } });
    if (!story) throw new NotFoundException('Story not found');
    if (story.expiresAt < new Date()) throw new NotFoundException('Story has expired');

    // Upsert — ignore if already viewed
    await this.storyViewRepo
      .createQueryBuilder()
      .insert()
      .into(StoryView)
      .values({ storyId, viewerId })
      .orIgnore()
      .execute();

    return { message: 'Story viewed' };
  }

  async remove(storyId: string, userId: string) {
    const story = await this.storyRepo.findOne({ where: { id: storyId } });
    if (!story) throw new NotFoundException('Story not found');
    if (story.authorId !== userId) {
      throw new ForbiddenException('You can only delete your own stories');
    }
    await this.storyRepo.remove(story);
    return { message: 'Story deleted' };
  }
}
