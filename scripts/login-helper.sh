#!/bin/bash

# DockerHub Login Helper
# This script helps with DockerHub authentication

echo "🔐 DockerHub Login Helper"
echo "========================"
echo ""
echo "If you're having login issues, try these options:"
echo ""
echo "1. Use Personal Access Token (Recommended):"
echo "   - Visit: https://app.docker.com/settings"
echo "   - Create a new access token"
echo "   - Use token as password when prompted"
echo ""
echo "2. Check your credentials:"
echo "   - Verify username spelling"
echo "   - Try logging in at hub.docker.com first"
echo ""
echo "3. Two-Factor Authentication:"
echo "   - If 2FA is enabled, you MUST use a PAT"
echo ""

read -p "Enter your DockerHub username: " USERNAME

echo ""
echo "Attempting login for: $USERNAME"
echo "(Use your password or Personal Access Token when prompted)"

if docker login --username "$USERNAME"; then
    echo ""
    echo "✅ Successfully logged in!"
    echo "You can now run the deployment script:"
    echo "   ./scripts/dockerhub-deploy.sh"
else
    echo ""
    echo "❌ Login failed. Please check:"
    echo "1. Username: $USERNAME"
    echo "2. Password/Token is correct"
    echo "3. Account exists at hub.docker.com"
    echo "4. Try creating a Personal Access Token"
fi
