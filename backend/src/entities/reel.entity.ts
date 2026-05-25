import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  ManyToOne,
  OneToMany,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Comment } from './comment.entity';
import { ReelLike } from './reel-like.entity';

@Entity('reels')
export class Reel {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  authorId: string;

  @Column()
  videoUrl: string;

  @Column({ nullable: true, type: 'text' })
  caption: string;

  @Column({ nullable: true })
  audioTrack: string;

  @Column()
  duration: number;

  @Column({ default: 0 })
  viewsCount: number;

  @Column({ default: 0 })
  likesCount: number;

  @Column({ default: 0 })
  commentsCount: number;

  @Column('text', { array: true, default: [] })
  hashtags: string[];

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => User, (user) => user.reels, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'authorId' })
  author: User;

  @OneToMany(() => Comment, (comment) => comment.reel)
  comments: Comment[];

  @OneToMany(() => ReelLike, (like) => like.reel)
  likes: ReelLike[];
}
