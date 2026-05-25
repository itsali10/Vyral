import { Module } from '@nestjs/common';
import { TypeOrmModule } from '@nestjs/typeorm';
import { UsersController } from './users.controller';
import { UsersService } from './users.service';
import { User } from '../entities/user.entity';
import { Post } from '../entities/post.entity';
import { Reel } from '../entities/reel.entity';
import { SavedPost } from '../entities/saved-post.entity';

@Module({
  imports: [TypeOrmModule.forFeature([User, Post, Reel, SavedPost])],
  controllers: [UsersController],
  providers: [UsersService],
  exports: [UsersService],
})
export class UsersModule {}
