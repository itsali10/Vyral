import { Module } from '@nestjs/common';
import { ConfigModule, ConfigService } from '@nestjs/config';
import { TypeOrmModule } from '@nestjs/typeorm';
import { AppController } from './app.controller';
import { AppService } from './app.service';
import { SupabaseModule } from './supabase/supabase.module';
import { AuthModule } from './auth/auth.module';
import { UsersModule } from './users/users.module';
import { PostsModule } from './posts/posts.module';
import { ReelsModule } from './reels/reels.module';
import { StoriesModule } from './stories/stories.module';

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

const entities = [
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
    ReelsModule,
    StoriesModule,
  ],
  controllers: [AppController],
  providers: [AppService],
})
export class AppModule {}
