import 'dotenv/config';
import { DataSource } from 'typeorm';
import { User } from './entities/user.entity';
import { Follow } from './entities/follow.entity';
import { Post } from './entities/post.entity';
import { Comment } from './entities/comment.entity';
import { PostLike } from './entities/post-like.entity';
import { SavedPost } from './entities/saved-post.entity';
import { SavedCollection } from './entities/saved-collection.entity';
import { UserSettings } from './entities/user-settings.entity';
import { UserBlock } from './entities/user-block.entity';

export const AppDataSource = new DataSource({
  type: 'postgres',
  url: process.env.DATABASE_URL,
  ssl: { rejectUnauthorized: false },
  entities: [
    User,
    Follow,
    Post,
    Comment,
    PostLike,
    SavedPost,
    SavedCollection,
    UserSettings,
    UserBlock,
  ],
  migrations: ['src/migrations/*.ts'],
  synchronize: false,
  logging: false,
});
