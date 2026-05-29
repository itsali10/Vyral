import {
  Body,
  Controller,
  DefaultValuePipe,
  Delete,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { AuthGuard } from '../common/guards/auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { PostsService, FeedTab } from './posts.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';
import { CreateCommentDto } from './dto/create-comment.dto';

@ApiTags('Posts')
@ApiBearerAuth('access-token')
@UseGuards(AuthGuard)
@Controller('posts')
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  @Get('feed')
  @ApiOperation({ summary: 'Home feed: for_you | following | trending' })
  @ApiQuery({ name: 'tab', enum: ['for_you', 'following', 'trending'] })
  getFeed(
    @CurrentUser() user: { id: string },
    @Query('tab', new DefaultValuePipe('for_you')) tab: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number,
  ) {
    const feedTab = (['for_you', 'following', 'trending'].includes(tab)
      ? tab
      : 'for_you') as FeedTab;
    return this.postsService.getFeed(user.id, feedTab, page, limit);
  }

  @Post()
  @ApiOperation({ summary: 'Create a new post' })
  create(@CurrentUser() user: { id: string }, @Body() dto: CreatePostDto) {
    return this.postsService.create(user.id, dto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a post by ID (feed shape)' })
  findOne(@Param('id') id: string, @CurrentUser() user: { id: string }) {
    return this.postsService.findOneForViewer(id, user.id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a post (owner only)' })
  update(
    @Param('id') id: string,
    @CurrentUser() user: { id: string },
    @Body() dto: UpdatePostDto,
  ) {
    return this.postsService.update(id, user.id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a post (owner only)' })
  remove(@Param('id') id: string, @CurrentUser() user: { id: string }) {
    return this.postsService.remove(id, user.id);
  }

  @Post(':id/pin')
  @ApiOperation({ summary: 'Pin post to top of profile (owner only)' })
  pin(@Param('id') id: string, @CurrentUser() user: { id: string }) {
    return this.postsService.pin(id, user.id);
  }

  @Delete(':id/pin')
  @ApiOperation({ summary: 'Unpin post from profile (owner only)' })
  unpin(@Param('id') id: string, @CurrentUser() user: { id: string }) {
    return this.postsService.unpin(id, user.id);
  }

  @Post(':id/like')
  @ApiOperation({ summary: 'Like a post' })
  like(@Param('id') id: string, @CurrentUser() user: { id: string }) {
    return this.postsService.like(id, user.id);
  }

  @Delete(':id/like')
  @ApiOperation({ summary: 'Unlike a post' })
  unlike(@Param('id') id: string, @CurrentUser() user: { id: string }) {
    return this.postsService.unlike(id, user.id);
  }

  @Post(':id/save')
  @ApiOperation({ summary: 'Save a post to collection' })
  @ApiQuery({ name: 'collectionId', required: false })
  save(
    @Param('id') id: string,
    @CurrentUser() user: { id: string },
    @Query('collectionId') collectionId?: string,
  ) {
    return this.postsService.save(id, user.id, collectionId);
  }

  @Delete(':id/save')
  @ApiOperation({ summary: 'Unsave a post' })
  unsave(@Param('id') id: string, @CurrentUser() user: { id: string }) {
    return this.postsService.unsave(id, user.id);
  }

  @Get(':id/comments')
  @ApiOperation({ summary: 'List comments on a post' })
  getComments(
    @Param('id') id: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number,
  ) {
    return this.postsService.getComments(id, page, limit);
  }

  @Post(':id/comments')
  @ApiOperation({ summary: 'Add a comment' })
  addComment(
    @Param('id') id: string,
    @CurrentUser() user: { id: string },
    @Body() dto: CreateCommentDto,
  ) {
    return this.postsService.addComment(id, user.id, dto);
  }
}
