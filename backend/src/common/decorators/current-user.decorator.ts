import { createParamDecorator, ExecutionContext } from '@nestjs/common';
import type { User } from '@supabase/supabase-js';

export const CurrentUser = createParamDecorator(
  (_: unknown, ctx: ExecutionContext): User => {
    return ctx.switchToHttp().getRequest().user as User;
  },
);
