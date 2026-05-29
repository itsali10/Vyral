import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { User } from '../entities/user.entity';
import { Post } from '../entities/post.entity';
import { Reel } from '../entities/reel.entity';
import { SavedPost } from '../entities/saved-post.entity';
import { SavedCollection } from '../entities/saved-collection.entity';
import { Follow } from '../entities/follow.entity';
import { PostLike } from '../entities/post-like.entity';
import { Comment } from '../entities/comment.entity';
import { UserSettings } from '../entities/user-settings.entity';
import { UserBlock } from '../entities/user-block.entity';
import { SupabaseModule } from '../supabase/supabase.module';

@Module({
  imports: [
    TypeOrmModule.forFeature([
      User,
      Post,
      Reel,
      SavedPost,
      SavedCollection,
      Follow,
      PostLike,
      Comment,
      UserSettings,
      UserBlock,
    ]),
    SupabaseModule,
  ],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
