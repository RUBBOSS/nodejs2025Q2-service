@echo off
REM DockerHub Deployment Script for Home Library Service (Windows)
REM This script builds and pushes the Docker image to DockerHub

setlocal enabledelayedexpansion

echo 🐳 DockerHub Deployment Script for Home Library Service
echo ================================================

REM Configuration
set IMAGE_NAME=home-library-service
set DEFAULT_DOCKERHUB_USERNAME=your-dockerhub-username
set VERSION=%1
if "%VERSION%"=="" set VERSION=latest

REM Check if DockerHub username is provided
if "%DOCKERHUB_USERNAME%"=="" (
    echo ⚠️  DOCKERHUB_USERNAME environment variable not set
    echo    Using default: %DEFAULT_DOCKERHUB_USERNAME%
    echo    Set your username: set DOCKERHUB_USERNAME=your-username
    set DOCKERHUB_USERNAME=%DEFAULT_DOCKERHUB_USERNAME%
)

set FULL_IMAGE_NAME=%DOCKERHUB_USERNAME%/%IMAGE_NAME%:%VERSION%

echo 📋 Configuration:
echo    Docker Hub Username: %DOCKERHUB_USERNAME%
echo    Image Name: %IMAGE_NAME%
echo    Full Image: %FULL_IMAGE_NAME%
echo    Version: %VERSION%
echo.

REM Step 1: Build the Docker image
echo 🔨 Step 1: Building Docker image...
docker build -t %IMAGE_NAME% .
if %errorlevel% neq 0 (
    echo ❌ Failed to build Docker image
    exit /b 1
)
echo ✅ Docker image built successfully

REM Step 2: Tag the image for DockerHub
echo 🏷️  Step 2: Tagging image for DockerHub...
docker tag %IMAGE_NAME% %FULL_IMAGE_NAME%
if %errorlevel% neq 0 (
    echo ❌ Failed to tag image
    exit /b 1
)
echo ✅ Image tagged successfully

REM Step 3: Check if user is logged in to DockerHub
echo 🔐 Step 3: Checking DockerHub login status...
docker info | findstr "Username" >nul
if %errorlevel% neq 0 (
    echo ⚠️  Not logged in to DockerHub
    echo    Please login first: docker login
    set /p response="Do you want to login now? (y/N): "
    if /i "!response!"=="y" (
        docker login
        if %errorlevel% neq 0 (
            echo ❌ Login failed
            exit /b 1
        )
    ) else (
        echo ❌ Cannot push without DockerHub login
        exit /b 1
    )
)

REM Step 4: Push to DockerHub
echo 📤 Step 4: Pushing to DockerHub...
docker push %FULL_IMAGE_NAME%
if %errorlevel% neq 0 (
    echo ❌ Failed to push image to DockerHub
    exit /b 1
)
echo ✅ Image pushed to DockerHub successfully!

REM Step 5: Show image information
echo 📊 Step 5: Image Information
docker images | findstr %IMAGE_NAME%
echo.
echo 🎉 Deployment completed successfully!
echo 📍 Your image is available at: https://hub.docker.com/r/%DOCKERHUB_USERNAME%/%IMAGE_NAME%
echo.
echo 💡 To pull the image:
echo    docker pull %FULL_IMAGE_NAME%
echo.
echo 💡 To run the image:
echo    docker run -p 4000:4000 %FULL_IMAGE_NAME%

endlocal
