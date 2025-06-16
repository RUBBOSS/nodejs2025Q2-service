import {
  Injectable,
  UnauthorizedException,
  ForbiddenException,
  BadRequestException,
} from '@nestjs/common';
import { JwtService } from '@nestjs/jwt';
import { InjectRepository } from '@nestjs/typeorm';
import { Repository } from 'typeorm';
import * as bcrypt from 'bcryptjs';
import { User } from '../entities/user.entity';
import { AuthSignupDto } from '../dto/auth-signup.dto';
import { AuthLoginDto } from '../dto/auth-login.dto';
import { LoggingService } from '../shared/logging.service';

export interface TokenResponse {
  accessToken: string;
  refreshToken: string;
}

@Injectable()
export class AuthService {
  constructor(
    @InjectRepository(User)
    private userRepository: Repository<User>,
    private jwtService: JwtService,
    private loggingService: LoggingService,
  ) {}

  async signup(
    signupDto: AuthSignupDto,
  ): Promise<{ id: string; message: string }> {
    const { login, password } = signupDto;

    // Validate input
    if (
      !login ||
      !password ||
      typeof login !== 'string' ||
      typeof password !== 'string'
    ) {
      throw new BadRequestException(
        'Login and password must be provided as strings',
      );
    }

    // Check if user already exists
    const existingUser = await this.userRepository.findOne({
      where: { login },
    });

    if (existingUser) {
      throw new ForbiddenException('User with this login already exists');
    }

    // Hash password
    const saltRounds = parseInt(process.env.CRYPT_SALT || '10');
    const hashedPassword = await bcrypt.hash(password, saltRounds);

    // Create user
    const user = this.userRepository.create({
      login,
      password: hashedPassword,
      version: 1,
    });

    const savedUser = await this.userRepository.save(user);

    this.loggingService.log(`User created with login: ${login}`, 'AuthService');

    return { id: savedUser.id, message: 'User created successfully' };
  }

  async login(loginDto: AuthLoginDto): Promise<TokenResponse> {
    const { login, password } = loginDto;

    if (
      !login ||
      !password ||
      typeof login !== 'string' ||
      typeof password !== 'string'
    ) {
      throw new BadRequestException(
        'Login and password must be provided as strings',
      );
    }

    const user = await this.userRepository.findOne({
      where: { login },
    });

    if (!user) {
      throw new ForbiddenException('Authentication failed');
    }

    const isPasswordValid = await bcrypt.compare(password, user.password);
    if (!isPasswordValid) {
      throw new ForbiddenException('Authentication failed');
    }

    this.loggingService.log(`User logged in: ${login}`, 'AuthService');

    return this.generateTokens(user);
  }

  async refresh(refreshToken: string): Promise<TokenResponse> {
    if (!refreshToken || typeof refreshToken !== 'string') {
      throw new UnauthorizedException('Refresh token must be provided');
    }

    try {
      const decoded = this.jwtService.verify(refreshToken, {
        secret: process.env.JWT_SECRET_REFRESH_KEY,
      });

      const user = await this.userRepository.findOne({
        where: { id: decoded.userId },
      });

      if (!user) {
        throw new ForbiddenException('Invalid refresh token');
      }

      this.loggingService.log(
        `Token refreshed for user: ${user.login}`,
        'AuthService',
      );

      return this.generateTokens(user);
    } catch (error) {
      throw new ForbiddenException('Invalid or expired refresh token');
    }
  }

  private generateTokens(user: User): TokenResponse {
    const payload = { userId: user.id, login: user.login };

    const accessToken = this.jwtService.sign(payload, {
      secret: process.env.JWT_SECRET_KEY,
      expiresIn: process.env.TOKEN_EXPIRE_TIME || '1h',
    });

    const refreshToken = this.jwtService.sign(payload, {
      secret: process.env.JWT_SECRET_REFRESH_KEY,
      expiresIn: process.env.TOKEN_REFRESH_EXPIRE_TIME || '24h',
    });

    return { accessToken, refreshToken };
  }

  async validateUser(payload: any): Promise<User> {
    const user = await this.userRepository.findOne({
      where: { id: payload.userId },
    });

    if (!user) {
      throw new UnauthorizedException('Invalid token');
    }

    return user;
  }
}
