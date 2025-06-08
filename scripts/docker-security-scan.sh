#!/bin/bash

# Docker Security Scanning Script
# Scans Docker images for vulnerabilities using free tools

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
IMAGE_NAME="home-library-service"
REPORT_DIR="security-reports"

echo -e "${CYAN}🐳 Docker Security Scanning${NC}"
echo "==========================="
echo ""

# Create reports directory
mkdir -p "$REPORT_DIR"

# Check if Docker is available
if ! command -v docker >/dev/null 2>&1; then
    echo -e "${RED}❌ Docker not found${NC}"
    exit 1
fi

# Check if image exists
if ! docker images | grep -q "$IMAGE_NAME"; then
    echo -e "${YELLOW}⚠️  Image $IMAGE_NAME not found, building...${NC}"
    if ! docker build -t "$IMAGE_NAME" .; then
        echo -e "${RED}❌ Failed to build image${NC}"
        exit 1
    fi
fi

echo -e "${BLUE}🔍 Step 1: Docker Built-in Security Scan${NC}"
echo "========================================"

# Use Docker Scout if available (newer Docker versions)
if docker scout --help >/dev/null 2>&1; then
    echo -e "${CYAN}📋 Running Docker Scout scan...${NC}"
    docker scout cves "$IMAGE_NAME" > "$REPORT_DIR/docker-scout.txt" 2>&1 || echo "Docker Scout scan completed"
    echo -e "${GREEN}📄 Docker Scout report: security-reports/docker-scout.txt${NC}"
else
    echo -e "${YELLOW}⚠️  Docker Scout not available in this Docker version${NC}"
fi
echo ""

echo -e "${BLUE}🔍 Step 2: Image Analysis${NC}"
echo "========================="

# Analyze image layers and history
echo -e "${CYAN}📋 Analyzing image layers...${NC}"
docker history "$IMAGE_NAME" > "$REPORT_DIR/docker-history.txt"
echo -e "${GREEN}📄 Image history: security-reports/docker-history.txt${NC}"

# Get image details
docker inspect "$IMAGE_NAME" > "$REPORT_DIR/docker-inspect.json"
echo -e "${GREEN}📄 Image details: security-reports/docker-inspect.json${NC}"

# Check image size
IMAGE_SIZE=$(docker images --format "table {{.Size}}" "$IMAGE_NAME" | tail -n 1)
echo -e "${CYAN}📦 Image size: ${IMAGE_SIZE}${NC}"
echo ""

echo -e "${BLUE}🔍 Step 3: Security Best Practices Check${NC}"
echo "========================================"

# Check Dockerfile for security best practices
DOCKERFILE_ISSUES=()

if [ -f "Dockerfile" ]; then
    echo -e "${CYAN}📋 Analyzing Dockerfile...${NC}"
    
    # Check for root user
    if ! grep -q "USER.*[^root]" Dockerfile; then
        DOCKERFILE_ISSUES+=("⚠️  Running as root user - consider using non-root user")
    fi
    
    # Check for latest tag
    if grep -q "FROM.*:latest" Dockerfile; then
        DOCKERFILE_ISSUES+=("⚠️  Using 'latest' tag - consider pinning specific versions")
    fi
    
    # Check for COPY vs ADD
    if grep -q "^ADD" Dockerfile; then
        DOCKERFILE_ISSUES+=("⚠️  Using ADD instead of COPY - COPY is more secure")
    fi
    
    # Check for exposed ports
    EXPOSED_PORTS=$(grep "^EXPOSE" Dockerfile | wc -l)
    if [ "$EXPOSED_PORTS" -gt 3 ]; then
        DOCKERFILE_ISSUES+=("⚠️  Multiple ports exposed ($EXPOSED_PORTS) - minimize attack surface")
    fi
    
    # Check for secrets in build context
    if grep -q "secret\|password\|key\|token" Dockerfile; then
        DOCKERFILE_ISSUES+=("🚨 Potential secrets in Dockerfile - use build secrets or runtime env vars")
    fi
    
    if [ ${#DOCKERFILE_ISSUES[@]} -eq 0 ]; then
        echo -e "${GREEN}✅ Dockerfile follows security best practices${NC}"
    else
        echo -e "${YELLOW}Dockerfile security recommendations:${NC}"
        for issue in "${DOCKERFILE_ISSUES[@]}"; do
            echo "   $issue"
        done
    fi
else
    echo -e "${YELLOW}⚠️  No Dockerfile found${NC}"
fi
echo ""

echo -e "${BLUE}🔍 Step 4: Runtime Security Analysis${NC}"
echo "==================================="

# Test container capabilities
echo -e "${CYAN}📋 Testing container security...${NC}"

# Check if container runs with minimal privileges
docker run --rm "$IMAGE_NAME" id > "$REPORT_DIR/container-user.txt" 2>&1 || echo "User check completed"

# Check for sensitive mount points
CONTAINER_ID=$(docker run -d "$IMAGE_NAME" sleep 10)
if [ -n "$CONTAINER_ID" ]; then
    docker exec "$CONTAINER_ID" ls -la /proc 2>/dev/null > "$REPORT_DIR/proc-access.txt" || echo "Proc access check completed"
    docker exec "$CONTAINER_ID" mount 2>/dev/null > "$REPORT_DIR/mount-points.txt" || echo "Mount points check completed"
    docker stop "$CONTAINER_ID" >/dev/null 2>&1
    docker rm "$CONTAINER_ID" >/dev/null 2>&1
fi

echo -e "${GREEN}📄 Container security tests completed${NC}"
echo ""

echo -e "${BLUE}🔍 Step 5: Base Image Security${NC}"
echo "============================="

# Extract base image info
BASE_IMAGE=$(grep "^FROM" Dockerfile | head -1 | awk '{print $2}' 2>/dev/null || echo "unknown")
echo -e "${CYAN}📋 Base image: ${BASE_IMAGE}${NC}"

# Check if using official images
if [[ "$BASE_IMAGE" == *"node"* ]] && [[ "$BASE_IMAGE" != *"/"* ]]; then
    echo -e "${GREEN}✅ Using official Node.js image${NC}"
elif [[ "$BASE_IMAGE" == *"alpine"* ]]; then
    echo -e "${GREEN}✅ Using Alpine base (minimal attack surface)${NC}"
else
    echo -e "${YELLOW}⚠️  Consider using official or Alpine-based images${NC}"
fi
echo ""

echo -e "${BLUE}📊 Docker Security Summary${NC}"
echo "=========================="

# Generate Docker security summary
cat > "$REPORT_DIR/docker-security-summary.md" << EOF
# Docker Security Scan Summary
**Date:** $(date)
**Image:** $IMAGE_NAME
**Base Image:** $BASE_IMAGE
**Size:** $IMAGE_SIZE

## Scan Results

### Image Analysis
- Image history: \`docker-history.txt\`
- Image details: \`docker-inspect.json\`
- Container user: \`container-user.txt\`

### Security Checks
EOF

if command -v docker scout >/dev/null 2>&1; then
    echo "- Docker Scout scan: \`docker-scout.txt\`" >> "$REPORT_DIR/docker-security-summary.md"
fi

if [ ${#DOCKERFILE_ISSUES[@]} -gt 0 ]; then
    echo "" >> "$REPORT_DIR/docker-security-summary.md"
    echo "### Dockerfile Issues" >> "$REPORT_DIR/docker-security-summary.md"
    for issue in "${DOCKERFILE_ISSUES[@]}"; do
        echo "- $issue" >> "$REPORT_DIR/docker-security-summary.md"
    done
fi

echo "" >> "$REPORT_DIR/docker-security-summary.md"
echo "### Recommendations" >> "$REPORT_DIR/docker-security-summary.md"
echo "- Regularly update base images" >> "$REPORT_DIR/docker-security-summary.md"
echo "- Scan images before deployment" >> "$REPORT_DIR/docker-security-summary.md"
echo "- Use minimal base images (Alpine)" >> "$REPORT_DIR/docker-security-summary.md"
echo "- Run containers as non-root users" >> "$REPORT_DIR/docker-security-summary.md"
echo "- Limit container capabilities" >> "$REPORT_DIR/docker-security-summary.md"

echo -e "${GREEN}📄 Docker security summary: security-reports/docker-security-summary.md${NC}"
echo ""
echo -e "${GREEN}🎉 Docker security scan completed!${NC}"
echo ""
echo -e "${CYAN}💡 Next steps:${NC}"
echo "   1. Review Docker Scout results (if available)"
echo "   2. Update base image if vulnerabilities found"
echo "   3. Address Dockerfile security issues"
echo "   4. Regular image scanning in CI/CD"
echo "   5. Monitor for new vulnerabilities"
echo ""

# Exit with appropriate code
if [ ${#DOCKERFILE_ISSUES[@]} -lt 3 ]; then
    echo -e "${GREEN}✅ Docker security looks good${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  Multiple Docker security issues detected${NC}"
    exit 1
fi
