import {
  Entity,
  PrimaryColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Reel } from './reel.entity';

@Entity('reel_likes')
export class ReelLike {
  @PrimaryColumn()
  userId: string;

  @PrimaryColumn()
  reelId: string;

  @CreateDateColumn()
  createdAt: Date;

  @ManyToOne(() => User, (user) => user.reelLikes, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @ManyToOne(() => Reel, (reel) => reel.likes, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'reelId' })
  reel: Reel;
}
