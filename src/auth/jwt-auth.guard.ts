import {
  Injectable,
  ExecutionContext,
  UnauthorizedException,
} from '@nestjs/common';
import { AuthGuard } from '@nestjs/passport';
import { Reflector } from '@nestjs/core';

@Injectable()
export class JwtAuthGuard extends AuthGuard('jwt') {
  constructor(private reflector: Reflector) {
    super();
  }

  canActivate(context: ExecutionContext) {
    const request = context.switchToHttp().getRequest();
    const path = request.url;

    const publicPaths = [
      '/auth/signup',
      '/auth/login',
      '/auth/refresh',
      '/doc',
      '/health',
      '/',
    ];

    const isPublicPath = publicPaths.some((publicPath) => {
      if (publicPath === '/') {
        return path === '/';
      }
      return path.startsWith(publicPath);
    });

    if (isPublicPath) {
      return true;
    }

    return super.canActivate(context);
  }

  handleRequest(err: any, user: any) {
    if (err || !user) {
      throw new UnauthorizedException('Invalid or missing token');
    }
    return user;
  }
}
