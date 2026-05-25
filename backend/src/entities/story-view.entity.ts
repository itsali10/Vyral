import {
  Entity,
  PrimaryColumn,
  CreateDateColumn,
  ManyToOne,
  JoinColumn,
} from 'typeorm';
import { User } from './user.entity';
import { Story } from './story.entity';

@Entity('story_views')
export class StoryView {
  @PrimaryColumn()
  storyId: string;

  @PrimaryColumn()
  viewerId: string;

  @CreateDateColumn()
  viewedAt: Date;

  @ManyToOne(() => Story, (story) => story.views, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'storyId' })
  story: Story;

  @ManyToOne(() => User, (user) => user.storyViews, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'viewerId' })
  viewer: User;
}
