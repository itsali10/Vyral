import {
  Column,
  Entity,
  JoinColumn,
  OneToOne,
  PrimaryColumn,
} from 'typeorm';
import { User } from './user.entity';

@Entity('user_settings')
export class UserSettings {
  @PrimaryColumn('uuid')
  userId: string;

  @OneToOne(() => User, { onDelete: 'CASCADE' })
  @JoinColumn({ name: 'userId' })
  user: User;

  @Column({ default: true })
  showLikesPublicly: boolean;

  @Column({ default: true })
  notifLikes: boolean;

  @Column({ default: true })
  notifComments: boolean;

  @Column({ default: true })
  notifFollowers: boolean;

  @Column({ default: false })
  notifTrending: boolean;

  @Column({ default: false })
  dataSaver: boolean;

  @Column({ default: true })
  hapticsEnabled: boolean;

  @Column({ default: false })
  exploreGridCompact: boolean;

  @Column({ default: 'rose' })
  accentColor: string;

  @Column({ default: 'for_you' })
  defaultFeedTab: string;

  @Column('text', { array: true, default: () => "'{}'" })
  mutedWords: string[];
}
