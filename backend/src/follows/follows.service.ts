import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { Follow } from '../entities/follow.entity';
import { User } from '../entities/user.entity';
import { FollowStatus } from '../entities/enums';

@Injectable()
export class FollowsService {
  constructor(
    @InjectRepository(Follow)
    private readonly followRepo: Repository<Follow>,
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
  ) {}

  async follow(followerId: string, followingId: string) {
    if (followerId === followingId) {
      throw new BadRequestException('Cannot follow yourself');
    }
    const target = await this.userRepo.findOne({ where: { id: followingId } });
    if (!target) throw new NotFoundException('User not found');

    const existing = await this.followRepo.findOne({
      where: { followerId, followingId },
    });
    if (existing) {
      if (!target.isPrivate && existing.status !== FollowStatus.ACCEPTED) {
        existing.status = FollowStatus.ACCEPTED;
        await this.followRepo.save(existing);
      }
      return {
        following: true,
        pending: existing.status === FollowStatus.PENDING,
      };
    }

    await this.followRepo.save(
      this.followRepo.create({
        followerId,
        followingId,
        status: target.isPrivate ? FollowStatus.PENDING : FollowStatus.ACCEPTED,
      }),
    );
    return { following: true, pending: target.isPrivate };
  }

  async unfollow(followerId: string, followingId: string) {
    const existing = await this.followRepo.findOne({
      where: { followerId, followingId },
    });
    if (existing) await this.followRepo.remove(existing);
    return { following: false };
  }
}
