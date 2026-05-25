import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { Reel } from '../entities/reel.entity';
import { Follow } from '../entities/follow.entity';
import { ReelsService } from './reels.service';
import { ReelsController } from './reels.controller';
import { SupabaseModule } from '../supabase/supabase.module';

@Module({
  imports: [TypeOrmModule.forFeature([Reel, Follow]), SupabaseModule],
  controllers: [ReelsController],
  providers: [ReelsService],
  exports: [ReelsService],
})
export class ReelsModule {}
