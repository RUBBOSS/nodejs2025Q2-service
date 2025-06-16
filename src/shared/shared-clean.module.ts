import { Module, Global } from '@nestjs/common';
import { CleanupService } from './cleanup.service';

@Global()
@Module({
  providers: [CleanupService],
  exports: [CleanupService],
})
export class SharedModule {}
