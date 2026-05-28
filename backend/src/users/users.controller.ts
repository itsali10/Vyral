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
import { UsersService } from './users.service';
import { UpdateProfileDto } from './dto/update-profile.dto';
import { UpdateSettingsDto } from './dto/update-settings.dto';
import { CreateCollectionDto } from './dto/create-collection.dto';
import { AuthGuard } from '../common/guards/auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import type { User as SupabaseUser } from '@supabase/supabase-js';

@ApiTags('Users')
@ApiBearerAuth('access-token')
@Controller('users')
@UseGuards(AuthGuard)
export class UsersController {
  constructor(private readonly usersService: UsersService) {}

  @Get('me')
  @ApiOperation({ summary: 'Get own profile with stats' })
  getMe(@CurrentUser() user: SupabaseUser) {
    return this.usersService.getMe(user.id);
  }

  @Patch('me')
  @ApiOperation({ summary: 'Update own profile' })
  updateMe(@CurrentUser() user: SupabaseUser, @Body() dto: UpdateProfileDto) {
    return this.usersService.updateMe(user.id, dto);
  }

  @Delete('me')
  @ApiOperation({ summary: 'Delete own account' })
  deleteMe(@CurrentUser() user: SupabaseUser) {
    return this.usersService.deleteMe(user.id);
  }

  @Get('me/settings')
  @ApiOperation({ summary: 'Get notification and app preferences' })
  getSettings(@CurrentUser() user: SupabaseUser) {
    return this.usersService.getSettings(user.id);
  }

  @Patch('me/settings')
  @ApiOperation({ summary: 'Update notification and app preferences' })
  updateSettings(
    @CurrentUser() user: SupabaseUser,
    @Body() dto: UpdateSettingsDto,
  ) {
    return this.usersService.updateSettings(user.id, dto);
  }

  @Get('me/blocks')
  @ApiOperation({ summary: 'List blocked accounts' })
  getBlocks(@CurrentUser() user: SupabaseUser) {
    return this.usersService.getBlockedUsers(user.id);
  }

  @Post('me/blocks/:userId')
  @ApiOperation({ summary: 'Block a user' })
  blockUser(
    @CurrentUser() user: SupabaseUser,
    @Param('userId') blockedId: string,
  ) {
    return this.usersService.blockUser(user.id, blockedId);
  }

  @Delete('me/blocks/:userId')
  @ApiOperation({ summary: 'Unblock a user' })
  unblockUser(
    @CurrentUser() user: SupabaseUser,
    @Param('userId') blockedId: string,
  ) {
    return this.usersService.unblockUser(user.id, blockedId);
  }

  @Get('search')
  @ApiOperation({ summary: 'Search users by username or name' })
  @ApiQuery({ name: 'q', required: true })
  searchUsers(
    @CurrentUser() user: SupabaseUser,
    @Query('q') q: string,
  ) {
    return this.usersService.searchUsers(user.id, q);
  }

  @Get('me/saved/collections')
  @ApiOperation({ summary: 'List saved collections' })
  getCollections(@CurrentUser() user: SupabaseUser) {
    return this.usersService.getSavedCollections(user.id);
  }

  @Post('me/saved/collections')
  @ApiOperation({ summary: 'Create a saved collection' })
  createCollection(
    @CurrentUser() user: SupabaseUser,
    @Body() dto: CreateCollectionDto,
  ) {
    return this.usersService.createCollection(user.id, dto);
  }

  @Get('me/saved/collections/:collectionId/posts')
  @ApiOperation({ summary: 'Posts in a collection' })
  @ApiQuery({ name: 'page', required: false })
  @ApiQuery({ name: 'limit', required: false })
  getCollectionPosts(
    @CurrentUser() user: SupabaseUser,
    @Param('collectionId') collectionId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(12), ParseIntPipe) limit: number,
  ) {
    return this.usersService.getCollectionPosts(
      user.id,
      collectionId,
      page,
      limit,
    );
  }

  @Get('me/saved')
  @ApiOperation({ summary: 'Get saved posts (default collection)' })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 12 })
  getSaved(
    @CurrentUser() user: SupabaseUser,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(12), ParseIntPipe) limit: number,
  ) {
    return this.usersService.getSavedPosts(user.id, page, limit);
  }

  @Get('me/posts')
  @ApiOperation({ summary: 'Get own posts (feed shape)' })
  async getMyPosts(
    @CurrentUser() user: SupabaseUser,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(12), ParseIntPipe) limit: number,
  ) {
    const items = await this.usersService.getUserPosts(
      user.id,
      user.id,
      page,
      limit,
    );
    return { items };
  }

  @Get('me/pins')
  @ApiOperation({ summary: 'Get own pins grid' })
  async getMyPins(
    @CurrentUser() user: SupabaseUser,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(12), ParseIntPipe) limit: number,
  ) {
    const items = await this.usersService.getUserPins(user.id, page, limit);
    return { items };
  }

  @Get(':id')
  @ApiOperation({ summary: "Get a user's public profile" })
  getProfile(
    @CurrentUser() user: SupabaseUser,
    @Param('id') targetId: string,
  ) {
    return this.usersService.getProfile(user.id, targetId);
  }

  @Get(':id/posts')
  @ApiOperation({ summary: "Get a user's posts" })
  @ApiQuery({ name: 'page', required: false, example: 1 })
  @ApiQuery({ name: 'limit', required: false, example: 12 })
  async getUserPosts(
    @CurrentUser() user: SupabaseUser,
    @Param('id') targetId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(12), ParseIntPipe) limit: number,
  ) {
    const items = await this.usersService.getUserPosts(
      user.id,
      targetId,
      page,
      limit,
    );
    return { items };
  }

  @Get(':id/pins')
  @ApiOperation({ summary: "Get a user's pins grid" })
  async getUserPins(
    @Param('id') targetId: string,
    @Query('page', new DefaultValuePipe(1), ParseIntPipe) page: number,
    @Query('limit', new DefaultValuePipe(12), ParseIntPipe) limit: number,
  ) {
    const items = await this.usersService.getUserPins(targetId, page, limit);
    return { items };
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
