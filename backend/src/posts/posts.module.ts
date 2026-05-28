import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Post } from '../entities/post.entity';
import { PostLike } from '../entities/post-like.entity';
import { SavedPost } from '../entities/saved-post.entity';
import { SavedCollection } from '../entities/saved-collection.entity';
import { Comment } from '../entities/comment.entity';
import { Follow } from '../entities/follow.entity';
import { PostsService } from './posts.service';
import { PostsController } from './posts.controller';
import { SupabaseModule } from '../supabase/supabase.module';
import { UsersModule } from '../users/users.module';
@Module({
  imports: [
    UsersModule,
    TypeOrmModule.forFeature([
      Post,
      PostLike,
      SavedPost,
      SavedCollection,
      Comment,
      Follow,
    ]),
    SupabaseModule,
  ],
  controllers: [PostsController],
  providers: [PostsService],
  exports: [PostsService],
})
export class PostsModule {}
