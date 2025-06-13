import { Module, Global } from '@nestjs/common';
import { CleanupService } from './cleanup.service';
import { LoggingService } from './logging.service';
import { AllExceptionsFilter } from './all-exceptions.filter';
import { LoggingInterceptor } from './logging.interceptor';

@Global()
@Module({
  providers: [
    CleanupService,
    LoggingService,
    AllExceptionsFilter,
    LoggingInterceptor,
  ],
  exports: [
    CleanupService,
    LoggingService,
    AllExceptionsFilter,
    LoggingInterceptor,
  ],
})
export class SharedModule {}
