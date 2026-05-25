import {
  Entity,
  PrimaryGeneratedColumn,
  Column,
  CreateDateColumn,
  UpdateDateColumn,
  OneToMany,
} from 'typeorm';
import { Role } from './enums';
import { Post } from './post.entity';
import { Reel } from './reel.entity';
import { Story } from './story.entity';
import { Comment } from './comment.entity';
import { Follow } from './follow.entity';
import { PostLike } from './post-like.entity';
import { ReelLike } from './reel-like.entity';
import { SavedPost } from './saved-post.entity';
import { StoryView } from './story-view.entity';
import { Message } from './message.entity';
import { ConversationParticipant } from './conversation-participant.entity';
import { Notification } from './notification.entity';
import { Report } from './report.entity';

@Entity('users')
export class User {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column({ unique: true })
  username: string;

  @Column({ unique: true })
  email: string;

  @Column()
  fullName: string;

  @Column({ nullable: true, type: 'text' })
  bio: string;

  @Column({ nullable: true })
  avatarUrl: string;

  @Column({ nullable: true })
  websiteUrl: string;

  @Column({ nullable: true })
  pronouns: string;

  @Column({ default: false })
  isPrivate: boolean;

  @Column({ default: false })
  isVerified: boolean;

  @Column({ type: 'enum', enum: Role, default: Role.USER })
  role: Role;

  @Column({ nullable: true })
  fcmToken: string;

  @Column({ default: false })
  isSuspended: boolean;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @OneToMany(() => Post, (post) => post.author)
  posts: Post[];

  @OneToMany(() => Reel, (reel) => reel.author)
  reels: Reel[];

  @OneToMany(() => Story, (story) => story.author)
  stories: Story[];

  @OneToMany(() => Comment, (comment) => comment.author)
  comments: Comment[];

  @OneToMany(() => Message, (message) => message.sender)
  sentMessages: Message[];

  @OneToMany(() => PostLike, (like) => like.user)
  postLikes: PostLike[];

  @OneToMany(() => ReelLike, (like) => like.user)
  reelLikes: ReelLike[];

  @OneToMany(() => SavedPost, (save) => save.user)
  savedPosts: SavedPost[];

  @OneToMany(() => StoryView, (view) => view.viewer)
  storyViews: StoryView[];

  @OneToMany(() => Follow, (follow) => follow.follower)
  following: Follow[];

  @OneToMany(() => Follow, (follow) => follow.following)
  followers: Follow[];

  @OneToMany(() => ConversationParticipant, (cp) => cp.user)
  conversations: ConversationParticipant[];

  @OneToMany(() => Notification, (n) => n.recipient)
  notifications: Notification[];

  @OneToMany(() => Report, (r) => r.reporter)
  reports: Report[];
}
