import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AuthGuard } from '../common/guards/auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { StoriesService } from './stories.service';
import { CreateStoryDto } from './dto/create-story.dto';

@ApiTags('Stories')
@ApiBearerAuth('access-token')
@UseGuards(AuthGuard)
@Controller('stories')
export class StoriesController {
  constructor(private readonly storiesService: StoriesService) {}

  @Post()
  @ApiOperation({ summary: 'Post a new story (expires in 24h)' })
  create(@CurrentUser() user: any, @Body() dto: CreateStoryDto) {
    return this.storiesService.create(user.id, dto);
  }

  @Get('feed')
  @ApiOperation({ summary: 'Get stories feed from followed users (grouped by author)' })
  getFeed(@CurrentUser() user: any) {
    return this.storiesService.getFeed(user.id);
  }

  @Get('user/:userId')
  @ApiOperation({ summary: "Get all active stories for a specific user" })
  getByUser(@Param('userId') userId: string) {
    return this.storiesService.getByUser(userId);
  }

  @Post(':id/view')
  @ApiOperation({ summary: 'Mark a story as viewed' })
  view(@Param('id') id: string, @CurrentUser() user: any) {
    return this.storiesService.view(id, user.id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a story (owner only)' })
  remove(@Param('id') id: string, @CurrentUser() user: any) {
    return this.storiesService.remove(id, user.id);
  }
}
