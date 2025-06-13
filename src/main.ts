import { NestFactory } from '@nestjs/core';
import { AppModule } from './app.module';
import { DocumentBuilder, SwaggerModule } from '@nestjs/swagger';
import { ValidationPipe } from '@nestjs/common';
import { config } from 'dotenv';
import { LoggingService } from './shared/logging.service';
import { AllExceptionsFilter } from './shared/all-exceptions.filter';
import { LoggingInterceptor } from './shared/logging.interceptor';

config();

async function bootstrap() {
  const app = await NestFactory.create(AppModule);

  const loggingService = app.get(LoggingService);

  setupGlobalExceptionHandlers(loggingService);

  const allExceptionsFilter = app.get(AllExceptionsFilter);
  app.useGlobalFilters(allExceptionsFilter);

  const loggingInterceptor = app.get(LoggingInterceptor);
  app.useGlobalInterceptors(loggingInterceptor);

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      transform: true,
    }),
  );

  const config = new DocumentBuilder()
    .setTitle('Home Library Service')
    .setDescription('Home music library service')
    .setVersion('1.0.0')
    .addBearerAuth()
    .build();

  const document = SwaggerModule.createDocument(app, config);
  SwaggerModule.setup('doc', app, document);

  const port = process.env.PORT || 4000;
  await app.listen(port);

  loggingService.log(
    `Application is running on: http://localhost:${port}`,
    'Bootstrap',
  );
  loggingService.log(
    `OpenAPI documentation available at: http://localhost:${port}/doc`,
    'Bootstrap',
  );
}

function setupGlobalExceptionHandlers(loggingService: LoggingService) {
  process.on('uncaughtException', (error: Error) => {
    loggingService.error(
      `Uncaught Exception: ${error.message}`,
      error.stack,
      'UncaughtException',
    );

    setTimeout(() => {
      process.exit(1);
    }, 1000);
  });

  process.on('unhandledRejection', (reason: any, promise: Promise<any>) => {
    const errorMessage =
      reason instanceof Error ? reason.message : String(reason);
    const errorStack = reason instanceof Error ? reason.stack : undefined;

    loggingService.error(
      `Unhandled Rejection at: ${promise}, reason: ${errorMessage}`,
      errorStack,
      'UnhandledRejection',
    );
  });

  process.on('SIGTERM', () => {
    loggingService.log('SIGTERM received, shutting down gracefully', 'Process');
  });

  process.on('SIGINT', () => {
    loggingService.log('SIGINT received, shutting down gracefully', 'Process');
  });
}
bootstrap();
