import {
  Controller,
  DefaultValuePipe,
  Get,
  ParseIntPipe,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { AuthGuard } from '../common/guards/auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { PostsService } from '../posts/posts.service';

@ApiTags('Explore')
@ApiBearerAuth('access-token')
@UseGuards(AuthGuard)
@Controller('explore')
export class ExploreController {
  constructor(private readonly postsService: PostsService) {}

  @Get('posts')
  @ApiOperation({ summary: 'Explore/search posts for masonry grid' })
  @ApiQuery({ name: 'q', required: false })
  @ApiQuery({ name: 'category', required: false, example: 'fashion' })
  search(
    @CurrentUser() user: { id: string },
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(20), ParseIntPipe) limit: number,
    @Query('q') q?: string,
    @Query('category') category?: string,
  ) {
    return this.postsService.explore(user.id, q, category, page, limit);
  }
}
