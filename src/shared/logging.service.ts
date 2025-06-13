import { Injectable, LogLevel } from '@nestjs/common';
import * as fs from 'fs';
import * as path from 'path';

export interface LogEntry {
  timestamp: string;
  level: string;
  message: string;
  context?: string;
  trace?: string;
  pid: number;
}

@Injectable()
export class LoggingService {
  private readonly logLevels: LogLevel[] = [
    'error',
    'warn',
    'log',
    'debug',
    'verbose',
  ];
  private readonly logDir = path.join(process.cwd(), 'logs');
  private readonly logFile = path.join(this.logDir, 'application.log');
  private readonly errorFile = path.join(this.logDir, 'error.log');
  private readonly maxFileSize: number;
  private readonly logLevel: number;

  constructor() {
    if (!fs.existsSync(this.logDir)) {
      fs.mkdirSync(this.logDir, { recursive: true });
    }

    this.maxFileSize =
      parseInt(process.env.LOG_MAX_FILE_SIZE_KB || '1024', 10) * 1024; // Convert KB to bytes
    this.logLevel = this.getLogLevelFromEnv();
  }

  private getLogLevelFromEnv(): number {
    const envLogLevel = process.env.LOG_LEVEL || 'log';
    const levelIndex = this.logLevels.indexOf(envLogLevel as LogLevel);
    return levelIndex >= 0 ? levelIndex : 2; // Default to 'log' level (index 2)
  }

  private shouldLog(level: LogLevel): boolean {
    const levelIndex = this.logLevels.indexOf(level);
    return levelIndex <= this.logLevel;
  }

  private formatLogEntry(
    level: string,
    message: string,
    context?: string,
    trace?: string,
  ): LogEntry {
    return {
      timestamp: new Date().toISOString(),
      level: level.toUpperCase(),
      message,
      context,
      trace,
      pid: process.pid,
    };
  }

  private formatLogLine(entry: LogEntry): string {
    let logLine = `[${entry.timestamp}] [${entry.level}] [PID:${entry.pid}]`;

    if (entry.context) {
      logLine += ` [${entry.context}]`;
    }

    logLine += ` ${entry.message}`;

    if (entry.trace) {
      logLine += `\n${entry.trace}`;
    }

    return logLine + '\n';
  }

  private rotateLogFile(filePath: string): void {
    try {
      if (fs.existsSync(filePath)) {
        const stats = fs.statSync(filePath);
        if (stats.size >= this.maxFileSize) {
          const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
          const rotatedFile = filePath.replace(/\.log$/, `-${timestamp}.log`);
          fs.renameSync(filePath, rotatedFile);
        }
      }
    } catch (error) {
      console.error('Error rotating log file:', error);
    }
  }

  private writeToFile(filePath: string, logLine: string): void {
    try {
      this.rotateLogFile(filePath);
      fs.appendFileSync(filePath, logLine);
    } catch (error) {
      console.error('Error writing to log file:', error);
    }
  }

  private logToConsoleAndFile(
    level: LogLevel,
    message: string,
    context?: string,
    trace?: string,
  ): void {
    if (!this.shouldLog(level)) {
      return;
    }

    const entry = this.formatLogEntry(level, message, context, trace);
    const logLine = this.formatLogLine(entry);

    // Write to console
    console.log(logLine.trim());

    // Write to main log file
    this.writeToFile(this.logFile, logLine);

    // Write errors to separate error file
    if (level === 'error') {
      this.writeToFile(this.errorFile, logLine);
    }
  }

  error(message: string, trace?: string, context?: string): void {
    this.logToConsoleAndFile('error', message, context, trace);
  }

  warn(message: string, context?: string): void {
    this.logToConsoleAndFile('warn', message, context);
  }

  log(message: string, context?: string): void {
    this.logToConsoleAndFile('log', message, context);
  }

  debug(message: string, context?: string): void {
    this.logToConsoleAndFile('debug', message, context);
  }

  verbose(message: string, context?: string): void {
    this.logToConsoleAndFile('verbose', message, context);
  }

  logRequest(
    method: string,
    url: string,
    query?: any,
    body?: any,
    userAgent?: string,
  ): void {
    const requestInfo = {
      method,
      url,
      query: query && Object.keys(query).length > 0 ? query : undefined,
      body:
        body && Object.keys(body).length > 0
          ? this.sanitizeBody(body)
          : undefined,
      userAgent,
      timestamp: new Date().toISOString(),
    };

    this.log(`Incoming Request: ${JSON.stringify(requestInfo)}`, 'HTTP');
  }

  logResponse(
    method: string,
    url: string,
    statusCode: number,
    responseTime?: number,
  ): void {
    const responseInfo = {
      method,
      url,
      statusCode,
      responseTime: responseTime ? `${responseTime}ms` : undefined,
      timestamp: new Date().toISOString(),
    };

    this.log(`Outgoing Response: ${JSON.stringify(responseInfo)}`, 'HTTP');
  }

  private sanitizeBody(body: any): any {
    if (!body || typeof body !== 'object') {
      return body;
    }

    const sanitized = { ...body };
    const sensitiveFields = ['password', 'token', 'secret', 'authorization'];

    for (const field of sensitiveFields) {
      if (sanitized[field]) {
        sanitized[field] = '***REDACTED***';
      }
    }

    return sanitized;
  }
}
