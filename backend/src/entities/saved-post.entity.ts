import {
  Entity,
  PrimaryColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Post } from './post.entity';

@Entity('saved_posts')
export class SavedPost {
  @PrimaryColumn()
  userId: string;

  @PrimaryColumn()
  postId: string;

  @CreateDateColumn()
  savedAt: Date;

  @ManyToOne(() => User, (user) => user.savedPosts, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @ManyToOne(() => Post, (post) => post.saves, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'postId' })
  post: Post;
}
