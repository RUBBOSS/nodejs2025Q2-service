#!/bin/bash

# Security and Vulnerability Scanning Script
# Uses free tools to scan for vulnerabilities in dependencies

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
REPORT_DIR="$PROJECT_DIR/security-reports"

echo -e "${CYAN}🔒 Security & Vulnerability Scanning${NC}"
echo "====================================="
echo ""

# Create reports directory
mkdir -p "$REPORT_DIR"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install npm package globally if not exists
install_if_missing() {
    local package=$1
    local command=$2
    
    if ! command_exists "$command"; then
        echo -e "${YELLOW}📦 Installing $package...${NC}"
        npm install -g "$package" || {
            echo -e "${RED}❌ Failed to install $package${NC}"
            return 1
        }
    fi
}

echo -e "${BLUE}🔍 Step 1: NPM Audit (Built-in)${NC}"
echo "================================"

# Run npm audit
if npm audit --audit-level=moderate; then
    echo -e "${GREEN}✅ No moderate+ vulnerabilities found${NC}"
else
    echo -e "${YELLOW}⚠️  Vulnerabilities detected, check output above${NC}"
fi

# Save audit results
npm audit --json > "$REPORT_DIR/npm-audit.json" 2>/dev/null || echo "Audit report saved"
echo -e "${GREEN}📄 Audit report saved to: security-reports/npm-audit.json${NC}"
echo ""

echo -e "${BLUE}🔍 Step 2: Dependency Analysis${NC}"
echo "==============================="

# Check for outdated packages
echo -e "${CYAN}📋 Checking for outdated packages...${NC}"
npm outdated > "$REPORT_DIR/outdated-packages.txt" 2>/dev/null || echo "Outdated packages report generated"
echo -e "${GREEN}📄 Outdated packages report: security-reports/outdated-packages.txt${NC}"

# List all dependencies with versions
echo -e "${CYAN}📋 Generating dependency tree...${NC}"
npm list --depth=0 > "$REPORT_DIR/dependency-tree.txt" 2>/dev/null || echo "Dependency tree generated"
echo -e "${GREEN}📄 Dependency tree: security-reports/dependency-tree.txt${NC}"
echo ""

echo -e "${BLUE}🔍 Step 3: License Scanning${NC}"
echo "============================"

# Install license checker if needed
if install_if_missing "license-checker" "license-checker"; then
    echo -e "${CYAN}📋 Scanning licenses...${NC}"
    license-checker --onlyAllow 'MIT;Apache-2.0;BSD-2-Clause;BSD-3-Clause;ISC;Unlicense;WTFPL' \
        --excludePrivatePackages \
        --json > "$REPORT_DIR/licenses.json" 2>/dev/null || echo "License scan completed"
    
    # Generate summary
    license-checker --summary > "$REPORT_DIR/license-summary.txt" 2>/dev/null || echo "License summary generated"
    echo -e "${GREEN}📄 License report: security-reports/licenses.json${NC}"
    echo -e "${GREEN}📄 License summary: security-reports/license-summary.txt${NC}"
else
    echo -e "${YELLOW}⚠️  Skipping license check (installation failed)${NC}"
fi
echo ""

echo -e "${BLUE}🔍 Step 4: Package Vulnerability Database${NC}"
echo "=========================================="

# Check if we have internet connectivity
if curl -s --head --request GET https://registry.npmjs.org > /dev/null; then
    echo -e "${CYAN}📋 Checking package vulnerabilities...${NC}"
    
    # Use npm audit in different formats
    npm audit --format json > "$REPORT_DIR/npm-audit-detailed.json" 2>/dev/null || echo "Detailed audit saved"
    
    echo -e "${GREEN}📄 Detailed audit: security-reports/npm-audit-detailed.json${NC}"
else
    echo -e "${YELLOW}⚠️  No internet connectivity, skipping online vulnerability checks${NC}"
fi
echo ""

echo -e "${BLUE}🔍 Step 5: Code Quality & Security Patterns${NC}"
echo "==========================================="

# Check for common security anti-patterns in package.json
echo -e "${CYAN}📋 Analyzing package.json for security issues...${NC}"

SECURITY_ISSUES=()

# Check for wildcards in dependencies
if grep -q "\*\|^" "$PROJECT_DIR/package.json"; then
    SECURITY_ISSUES+=("⚠️  Wildcard or caret versions detected - consider pinning versions")
fi

# Check for scripts that might be dangerous
if grep -q "rm -rf\|sudo\|chmod 777" "$PROJECT_DIR/package.json"; then
    SECURITY_ISSUES+=("🚨 Potentially dangerous scripts detected")
fi

# Check for dev dependencies in production
DEV_DEPS=$(jq -r '.devDependencies | keys[]' "$PROJECT_DIR/package.json" 2>/dev/null | wc -l)
if [ "$DEV_DEPS" -gt 50 ]; then
    SECURITY_ISSUES+=("⚠️  Large number of dev dependencies ($DEV_DEPS) - review if all are needed")
fi

if [ ${#SECURITY_ISSUES[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ No obvious security issues in package.json${NC}"
else
    echo -e "${YELLOW}Security recommendations:${NC}"
    for issue in "${SECURITY_ISSUES[@]}"; do
        echo "   $issue"
    done
fi
echo ""

echo -e "${BLUE}🔍 Step 6: Environment & Configuration Security${NC}"
echo "==============================================="

# Check for sensitive files
echo -e "${CYAN}📋 Checking for sensitive files...${NC}"

SENSITIVE_FILES=()
if [ -f "$PROJECT_DIR/.env" ]; then
    SENSITIVE_FILES+=(".env file present - ensure it's in .gitignore")
fi

if [ -f "$PROJECT_DIR/.npmrc" ]; then
    SENSITIVE_FILES+=(".npmrc file present - check for sensitive tokens")
fi

if [ ${#SENSITIVE_FILES[@]} -eq 0 ]; then
    echo -e "${GREEN}✅ No sensitive files detected${NC}"
else
    echo -e "${YELLOW}Sensitive files found:${NC}"
    for file in "${SENSITIVE_FILES[@]}"; do
        echo "   ⚠️  $file"
    done
fi
echo ""

echo -e "${BLUE}📊 Security Scan Summary${NC}"
echo "========================"

# Generate summary report
cat > "$REPORT_DIR/security-summary.md" << EOF
# Security Scan Summary
**Date:** $(date)
**Project:** Home Library Service

## Scan Results

### NPM Audit
- Audit completed and saved to \`npm-audit.json\`
- Detailed results in \`npm-audit-detailed.json\`

### Dependencies
- Dependency tree: \`dependency-tree.txt\`
- Outdated packages: \`outdated-packages.txt\`

### Licenses
- License scan: \`licenses.json\`
- License summary: \`license-summary.txt\`

### Security Recommendations
EOF

if [ ${#SECURITY_ISSUES[@]} -gt 0 ]; then
    echo "#### Package.json Issues" >> "$REPORT_DIR/security-summary.md"
    for issue in "${SECURITY_ISSUES[@]}"; do
        echo "- $issue" >> "$REPORT_DIR/security-summary.md"
    done
fi

if [ ${#SENSITIVE_FILES[@]} -gt 0 ]; then
    echo "#### Sensitive Files" >> "$REPORT_DIR/security-summary.md"
    for file in "${SENSITIVE_FILES[@]}"; do
        echo "- $file" >> "$REPORT_DIR/security-summary.md"
    done
fi

echo -e "${GREEN}📄 Security summary: security-reports/security-summary.md${NC}"
echo ""

echo -e "${GREEN}🎉 Security scan completed!${NC}"
echo "============================="
echo ""
echo -e "${BLUE}📂 All reports saved to:${NC} security-reports/"
echo -e "${BLUE}📋 View summary:${NC} cat security-reports/security-summary.md"
echo ""
echo -e "${CYAN}💡 Next steps:${NC}"
echo "   1. Review npm audit results for critical vulnerabilities"
echo "   2. Update outdated packages: npm update"
echo "   3. Fix vulnerabilities: npm audit fix"
echo "   4. Check license compatibility for your use case"
echo "   5. Regular scans: npm run security"
echo ""

# Return appropriate exit code based on audit results
if npm audit --audit-level=high --dry-run >/dev/null 2>&1; then
    echo -e "${GREEN}✅ No high/critical vulnerabilities detected${NC}"
    exit 0
else
    echo -e "${YELLOW}⚠️  High/critical vulnerabilities detected - review and fix${NC}"
    exit 1
fi
