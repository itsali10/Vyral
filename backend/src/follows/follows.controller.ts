import { Controller, Delete, Param, Post, UseGuards } from '@nestjs/common';
import { ApiBearerAuth, ApiOperation, ApiTags } from '@nestjs/swagger';
import { AuthGuard } from '../common/guards/auth.guard';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { FollowsService } from './follows.service';

@ApiTags('Follows')
@ApiBearerAuth('access-token')
@UseGuards(AuthGuard)
@Controller('users')
export class FollowsController {
  constructor(private readonly followsService: FollowsService) {}

  @Post(':id/follow')
  @ApiOperation({ summary: 'Follow a user' })
  follow(
    @CurrentUser() user: { id: string },
    @Param('id') targetId: string,
  ) {
    return this.followsService.follow(user.id, targetId);
  }

  @Delete(':id/follow')
  @ApiOperation({ summary: 'Unfollow a user' })
  unfollow(
    @CurrentUser() user: { id: string },
    @Param('id') targetId: string,
  ) {
    return this.followsService.unfollow(user.id, targetId);
  }
}
