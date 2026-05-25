import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Story } from '../entities/story.entity';
import { StoryView } from '../entities/story-view.entity';
import { Follow } from '../entities/follow.entity';
import { StoriesService } from './stories.service';
import { StoriesController } from './stories.controller';
import { SupabaseModule } from '../supabase/supabase.module';

@Module({
  imports: [TypeOrmModule.forFeature([Story, StoryView, Follow]), SupabaseModule],
  controllers: [StoriesController],
  providers: [StoriesService],
  exports: [StoriesService],
})
export class StoriesModule {}
