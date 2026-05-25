import {
  BadRequestException,
  ConflictException,
  Injectable,
  InternalServerErrorException,
  UnauthorizedException,
} from '@nestjs/common';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import { SupabaseService } from '../supabase/supabase.service';
import { User } from '../entities/user.entity';
import { RegisterDto } from './dto/register.dto';
import { LoginDto } from './dto/login.dto';
import { GoogleAuthDto } from './dto/google-auth.dto';
import { ForgotPasswordDto } from './dto/forgot-password.dto';
import { ResetPasswordDto } from './dto/reset-password.dto';
import { RefreshDto } from './dto/refresh.dto';

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private readonly userRepo: Repository<User>,
    private readonly supabase: SupabaseService,
  ) {}

  async register(dto: RegisterDto) {
    const taken = await this.userRepo.findOne({
      where: { username: dto.username },
    });
    if (taken) throw new ConflictException('Username already taken');

    // Create auth user with email pre-confirmed (no verification email for mobile MVP)
    const { data, error } = await this.supabase
      .getAdminClient()
      .auth.admin.createUser({
        email: dto.email,
        password: dto.password,
        email_confirm: true,
      });

    if (error) {
      if (error.message.toLowerCase().includes('already registered')) {
        throw new ConflictException('Email already registered');
      }
      throw new BadRequestException(error.message);
    }

    const user = this.userRepo.create({
      id: data.user.id,
      email: dto.email,
      username: dto.username,
      fullName: dto.fullName,
    });
    await this.userRepo.save(user);

    const { data: session, error: signInError } = await this.supabase
      .getClient()
      .auth.signInWithPassword({ email: dto.email, password: dto.password });

    if (signInError || !session.session) {
      throw new InternalServerErrorException('Account created but login failed');
    }

    return {
      user: this.sanitize(user),
      session: this.formatSession(session.session),
    };
  }

  async login(dto: LoginDto) {
    const { data, error } = await this.supabase
      .getClient()
      .auth.signInWithPassword({ email: dto.email, password: dto.password });

    if (error || !data.session) {
      throw new UnauthorizedException('Invalid email or password');
    }

    const user = await this.userRepo.findOne({
      where: { id: data.user.id },
    });

    if (!user) {
      throw new UnauthorizedException('Account not found');
    }

    if (user.isSuspended) {
      throw new UnauthorizedException('Account is suspended');
    }

    return {
      user: this.sanitize(user),
      session: this.formatSession(data.session),
    };
  }

  async googleAuth(dto: GoogleAuthDto) {
    const { data, error } = await this.supabase
      .getClient()
      .auth.signInWithIdToken({ provider: 'google', token: dto.idToken });

    if (error || !data.session) {
      throw new UnauthorizedException('Invalid Google token');
    }

    let user = await this.userRepo.findOne({ where: { id: data.user.id } });

    if (!user) {
      const googleName = data.user.user_metadata?.full_name ?? 'User';
      const baseUsername = googleName.toLowerCase().replace(/\s+/g, '_');
      const username = `${baseUsername}_${data.user.id.slice(0, 6)}`;

      user = this.userRepo.create({
        id: data.user.id,
        email: data.user.email!,
        fullName: googleName,
        username,
        avatarUrl: data.user.user_metadata?.avatar_url ?? null,
      });
      await this.userRepo.save(user);
    }

    if (user.isSuspended) {
      throw new UnauthorizedException('Account is suspended');
    }

    return {
      user: this.sanitize(user),
      session: this.formatSession(data.session),
      isNewUser: !user.createdAt,
    };
  }

  async logout(accessToken: string) {
    const { error } = await this.supabase.getClient().auth.signOut();
    if (error) throw new InternalServerErrorException('Logout failed');
    return { message: 'Logged out successfully' };
  }

  async forgotPassword(dto: ForgotPasswordDto) {
    const { error } = await this.supabase
      .getClient()
      .auth.resetPasswordForEmail(dto.email);

    // Always return success to avoid email enumeration
    if (error) console.error('Forgot password error:', error.message);

    return { message: 'If an account exists, a reset email has been sent' };
  }

  async resetPassword(dto: ResetPasswordDto) {
    const supabase = this.supabase.getClient();

    // Set the session from the recovery token before updating
    const { error: sessionError } = await supabase.auth.setSession({
      access_token: dto.accessToken,
      refresh_token: '',
    });

    if (sessionError) {
      throw new BadRequestException('Invalid or expired reset token');
    }

    const { error } = await supabase.auth.updateUser({
      password: dto.newPassword,
    });

    if (error) throw new BadRequestException(error.message);

    return { message: 'Password updated successfully' };
  }

  async refresh(dto: RefreshDto) {
    const { data, error } = await this.supabase
      .getClient()
      .auth.refreshSession({ refresh_token: dto.refreshToken });

    if (error || !data.session) {
      throw new UnauthorizedException('Invalid or expired refresh token');
    }

    return { session: this.formatSession(data.session) };
  }

  private sanitize(user: User) {
    const { ...safe } = user;
    return safe;
  }

  private formatSession(session: {
    access_token: string;
    refresh_token: string;
    expires_in: number;
  }) {
    return {
      accessToken: session.access_token,
      refreshToken: session.refresh_token,
      expiresIn: session.expires_in,
    };
  }
}
