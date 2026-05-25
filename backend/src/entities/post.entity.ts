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
import { PostType } from './enums';
import { User } from './user.entity';
import { Comment } from './comment.entity';
import { PostLike } from './post-like.entity';
import { SavedPost } from './saved-post.entity';

@Entity('posts')
export class Post {
  @PrimaryGeneratedColumn('uuid')
  id: string;

  @Column()
  authorId: string;

  @Column({ nullable: true, type: 'text' })
  caption: string;

  @Column('text', { array: true, default: [] })
  mediaUrls: string[];

  @Column({ type: 'enum', enum: PostType })
  type: PostType;

  @Column('text', { array: true, default: [] })
  hashtags: string[];

  @Column({ nullable: true })
  location: string;

  @Column({ default: 0 })
  likesCount: number;

  @Column({ default: 0 })
  commentsCount: number;

  @Column({ default: 0 })
  savesCount: number;

  @CreateDateColumn()
  createdAt: Date;

  @UpdateDateColumn()
  updatedAt: Date;

  @ManyToOne(() => User, (user) => user.posts, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'authorId' })
  author: User;

  @OneToMany(() => Comment, (comment) => comment.post)
  comments: Comment[];

  @OneToMany(() => PostLike, (like) => like.post)
  likes: PostLike[];

  @OneToMany(() => SavedPost, (save) => save.post)
  saves: SavedPost[];
}
