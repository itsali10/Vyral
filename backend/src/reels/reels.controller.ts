import {
  Body,
  Controller,
  Delete,
  Get,
  Param,
  Post,
  Query,
  UseGuards,
} from '@nestjs/common';
import {
  ApiBearerAuth,
  ApiOperation,
  ApiQuery,
  ApiTags,
} from '@nestjs/swagger';
import { AuthGuard } from '../common/guards/auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { ReelsService } from './reels.service';
import { CreateReelDto } from './dto/create-reel.dto';

@ApiTags('Reels')
@ApiBearerAuth('access-token')
@UseGuards(AuthGuard)
@Controller('reels')
export class ReelsController {
  constructor(private readonly reelsService: ReelsService) {}

  @Post()
  @ApiOperation({ summary: 'Upload a new reel' })
  create(@CurrentUser() user: any, @Body() dto: CreateReelDto) {
    return this.reelsService.create(user.id, dto);
  }

  @Get('feed')
  @ApiOperation({ summary: 'Get reels feed from followed users' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 10 })
  getFeed(
    @CurrentUser() user: any,
    @Query('page') page = '1',
    @Query('limit') limit = '10',
  ) {
    return this.reelsService.getFeed(user.id, +page, +limit);
  }

  @Get(':id')
  @ApiOperation({ summary: 'Get a reel by ID (increments view count)' })
  findOne(@Param('id') id: string) {
    return this.reelsService.findOne(id);
  }

  @Delete(':id')
  @ApiOperation({ summary: 'Delete a reel (owner only)' })
  remove(@Param('id') id: string, @CurrentUser() user: any) {
    return this.reelsService.remove(id, user.id);
  }
}
