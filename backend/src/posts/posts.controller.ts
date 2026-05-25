import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Patch,
  Post,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AuthGuard } from '../common/guards/auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { PostsService } from './posts.service';
import { CreatePostDto } from './dto/create-post.dto';
import { UpdatePostDto } from './dto/update-post.dto';

@ApiTags('Posts')
@ApiBearerAuth('access-token')
@UseGuards(AuthGuard)
@Controller('posts')
export class PostsController {
  constructor(private readonly postsService: PostsService) {}

  @Post()
  @ApiOperation({ summary: 'Create a new post' })
  create(@CurrentUser() user: any, @Body() dto: CreatePostDto) {
    return this.postsService.create(user.id, dto);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a post by ID' })
  findOne(@Param('id') id: string) {
    return this.postsService.findOne(id);
  }

  @Patch(':id')
  @ApiOperation({ summary: 'Update a post (owner only)' })
  update(
    @Param('id') id: string,
    @CurrentUser() user: any,
    @Body() dto: UpdatePostDto,
  ) {
    return this.postsService.update(id, user.id, dto);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a post (owner only)' })
  remove(@Param('id') id: string, @CurrentUser() user: any) {
    return this.postsService.remove(id, user.id);
  }
}
