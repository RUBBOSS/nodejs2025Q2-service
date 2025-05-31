import { Injectable } from '@nestjs/common';

@Injectable()
export class CleanupService {
  private cleanupCallbacks: Map<string, ((id: string) => void)[]> = new Map();

  registerCleanupCallback(entityType: string, callback: (id: string) => void) {
    if (!this.cleanupCallbacks.has(entityType)) {
      this.cleanupCallbacks.set(entityType, []);
    }
    this.cleanupCallbacks.get(entityType)!.push(callback);
  }

  performCleanup(entityType: string, id: string) {
    const callbacks = this.cleanupCallbacks.get(entityType) || [];
    callbacks.forEach((callback) => callback(id));
  }
}
