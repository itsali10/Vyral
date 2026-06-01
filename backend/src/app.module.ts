import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { SupabaseModule } from './supabase/supabase.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { PostsModule } from './posts/posts.module';
import { UploadModule } from './upload/upload.module';
import { ExploreModule } from './explore/explore.module';
import { FollowsModule } from './follows/follows.module';

import { User } from './entities/user.entity';
import { Follow } from './entities/follow.entity';
import { Post } from './entities/post.entity';
import { Comment } from './entities/comment.entity';
import { PostLike } from './entities/post-like.entity';
import { SavedPost } from './entities/saved-post.entity';
import { SavedCollection } from './entities/saved-collection.entity';
import { UserSettings } from './entities/user-settings.entity';
import { UserBlock } from './entities/user-block.entity';

const entities = [
  User,
  UserSettings,
  UserBlock,
  Follow,
  Post,
  Comment,
  PostLike,
  SavedPost,
  SavedCollection,
];

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true }),
    TypeOrmModule.forRootAsync({
      inject: [ConfigService],
      useFactory: (config: ConfigService) => ({
        type: 'postgres',
        url: config.getOrThrow<string>('DATABASE_URL'),
        ssl: { rejectUnauthorized: false },
        entities,
        synchronize: false,
        logging: false,
      }),
    }),
    SupabaseModule,
    AuthModule,
    UsersModule,
    PostsModule,
    UploadModule,
    ExploreModule,
    FollowsModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
