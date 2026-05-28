import { Module } from '@nestjs/common';
import { ExploreController } from './explore.controller';
import { PostsModule } from '../posts/posts.module';

@Module({
  imports: [PostsModule],
  controllers: [ExploreController],
})
export class ExploreModule {}
