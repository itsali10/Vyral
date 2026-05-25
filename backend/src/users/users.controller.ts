import {
  Body,
  Controller,
  DefaultValuePipe,
  Get,
  Param,
  ParseIntPipe,
  Patch,
  Query,
  UseGuards,
} from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiQuery, ApiTags } from '@nestjs/swagger';
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { AuthGuard } from '../common/guards/auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { User as SupabaseUser } from '@supabase/supabase-js';

@ApiTags('Users')
@ApiBearerAuth('access-token')
@Controller('users')
@UseGuards(AuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  // ── Own profile ───────────────────────────────────────────────────────────
  // NOTE: /me routes MUST be declared before /:id to avoid route conflicts

  @Get('me')
  @ApiOperation({ summary: 'Get own profile' })
  getMe(@CurrentUser() user: SupabaseUser) {
    return this.usersService.getMe(user.id);
  }

  @Patch('me')
  @ApiOperation({ summary: 'Update own profile' })
  updateMe(@CurrentUser() user: SupabaseUser, @Body() dto: UpdateProfileDto) {
    return this.usersService.updateMe(user.id, dto);
  }

  @Get('me/saved')
  @ApiOperation({ summary: 'Get own saved posts' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 12 })
  getSaved(
    @CurrentUser() user: SupabaseUser,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(12), ParseIntPipe) limit: number,
  ) {
    return this.usersService.getSavedPosts(user.id, page, limit);
  }

  // ── Public profile ────────────────────────────────────────────────────────

  @Get(':id')
  @ApiOperation({ summary: "Get a user's public profile" })
  getProfile(
    @CurrentUser() user: SupabaseUser,
    @Param('id') targetId: string,
  ) {
    return this.usersService.getProfile(user.id, targetId);
  }

  @Get(':id/posts')
  @ApiOperation({ summary: "Get a user's posts grid" })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 12 })
  getUserPosts(
    @CurrentUser() user: SupabaseUser,
    @Param('id') targetId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(12), ParseIntPipe) limit: number,
  ) {
    return this.usersService.getUserPosts(user.id, targetId, page, limit);
  }

  @Get(':id/reels')
  @ApiOperation({ summary: "Get a user's reels" })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 12 })
  getUserReels(
    @CurrentUser() user: SupabaseUser,
    @Param('id') targetId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(12), ParseIntPipe) limit: number,
  ) {
    return this.usersService.getUserReels(user.id, targetId, page, limit);
  }
}
