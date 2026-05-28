import {
  Entity,
  PrimaryColumn,
  Column,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Post } from './post.entity';
import { SavedCollection } from './saved-collection.entity';

@Entity('saved_posts')
export class SavedPost {
  @PrimaryColumn()
  userId: string;

  @PrimaryColumn()
  postId: string;

  @Column({ nullable: true })
  collectionId: string | null;

  @CreateDateColumn()
  savedAt: Date;

  @ManyToOne(() => User, (user) => user.savedPosts, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @ManyToOne(() => Post, (post) => post.saves, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'postId' })
  post: Post;

  @ManyToOne(() => SavedCollection, (collection) => collection.saves, {
    nullable: true,
    onDelete: 'SET NULL',
  })
  @JoinColumn({ name: 'collectionId' })
  collection: SavedCollection | null;
}
