import 'dotenv/config';
import { DataSource } from 'typeorm';
import { User } from './entities/user.entity';
import { Follow } from './entities/follow.entity';
import { Post } from './entities/post.entity';
import { Reel } from './entities/reel.entity';
import { Story } from './entities/story.entity';
import { StoryView } from './entities/story-view.entity';
import { Comment } from './entities/comment.entity';
import { PostLike } from './entities/post-like.entity';
import { ReelLike } from './entities/reel-like.entity';
import { SavedPost } from './entities/saved-post.entity';
import { Conversation } from './entities/conversation.entity';
import { ConversationParticipant } from './entities/conversation-participant.entity';
import { Message } from './entities/message.entity';
import { Notification } from './entities/notification.entity';
import { Report } from './entities/report.entity';

export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
  entities: [
    User,
    Follow,
    Post,
    Reel,
    Story,
    StoryView,
    Comment,
    PostLike,
    ReelLike,
    SavedPost,
    Conversation,
    ConversationParticipant,
    Message,
    Notification,
    Report,
  ],
  migrations: ['src/migrations/*.ts'],
  synchronize: false,
  logging: false,
});
