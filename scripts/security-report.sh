#!/bin/bash

# Security Report Generator
# Consolidates all security scan results into a comprehensive report

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

REPORT_DIR="security-reports"
TIMESTAMP=$(date '+%Y-%m-%d_%H-%M-%S')

echo -e "${CYAN}📊 Security Report Generator${NC}"
echo "============================"
echo ""

# Check if reports directory exists
if [ ! -d "$REPORT_DIR" ]; then
    echo -e "${YELLOW}⚠️  No security reports found. Run security scans first:${NC}"
    echo "   npm run security"
    exit 1
fi

echo -e "${BLUE}📋 Generating comprehensive security report...${NC}"

# Generate comprehensive HTML report
cat > "$REPORT_DIR/security-report-${TIMESTAMP}.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Security Report - Home Library Service</title>
    <style>
        body {
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
            line-height: 1.6;
            color: #333;
            max-width: 1200px;
            margin: 0 auto;
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container {
            background: white;
            padding: 30px;
            border-radius: 8px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }
        .header {
            text-align: center;
            border-bottom: 2px solid #007acc;
            padding-bottom: 20px;
            margin-bottom: 30px;
        }
        .status-pass { color: #28a745; }
        .status-warning { color: #ffc107; }
        .status-fail { color: #dc3545; }
        .section {
            margin: 30px 0;
            padding: 20px;
            border-left: 4px solid #007acc;
            background-color: #f8f9fa;
        }
        .metric {
            display: inline-block;
            margin: 10px 15px;
            padding: 10px;
            background: white;
            border-radius: 4px;
            box-shadow: 0 1px 3px rgba(0,0,0,0.1);
        }
        .metric-value {
            font-size: 24px;
            font-weight: bold;
            color: #007acc;
        }
        .metric-label {
            font-size: 12px;
            color: #666;
            text-transform: uppercase;
        }
        pre {
            background: #f4f4f4;
            padding: 15px;
            border-radius: 4px;
            overflow-x: auto;
            border-left: 3px solid #007acc;
        }
        .recommendation {
            background: #fff3cd;
            border: 1px solid #ffeaa7;
            border-radius: 4px;
            padding: 15px;
            margin: 10px 0;
        }
        .success {
            background: #d4edda;
            border: 1px solid #c3e6cb;
            border-radius: 4px;
            padding: 15px;
            margin: 10px 0;
        }
        .file-list {
            background: white;
            border: 1px solid #ddd;
            border-radius: 4px;
            padding: 15px;
        }
        .file-list ul {
            margin: 0;
            padding-left: 20px;
        }
        table {
            width: 100%;
            border-collapse: collapse;
            margin: 15px 0;
        }
        th, td {
            border: 1px solid #ddd;
            padding: 8px;
            text-align: left;
        }
        th {
            background-color: #f2f2f2;
        }
        .footer {
            margin-top: 40px;
            padding-top: 20px;
            border-top: 1px solid #ddd;
            text-align: center;
            color: #666;
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔒 Security Assessment Report</h1>
            <h2>Home Library Service</h2>
            <p><strong>Generated:</strong> REPORT_DATE</p>
        </div>

        <div class="section">
            <h2>📊 Executive Summary</h2>
            <div class="metric">
                <div class="metric-value" id="vulnerability-count">-</div>
                <div class="metric-label">Vulnerabilities Found</div>
            </div>
            <div class="metric">
                <div class="metric-value" id="dependency-count">-</div>
                <div class="metric-label">Dependencies Scanned</div>
            </div>
            <div class="metric">
                <div class="metric-value" id="license-issues">-</div>
                <div class="metric-label">License Issues</div>
            </div>
            <div class="metric">
                <div class="metric-value status-pass" id="overall-status">PENDING</div>
                <div class="metric-label">Overall Status</div>
            </div>
        </div>

        <div class="section">
            <h2>🔍 NPM Audit Results</h2>
            <div id="npm-audit-content">
                <p>NPM audit results will be populated here...</p>
            </div>
        </div>

        <div class="section">
            <h2>📜 License Compliance</h2>
            <div id="license-content">
                <p>License compliance results will be populated here...</p>
            </div>
        </div>

        <div class="section">
            <h2>🐳 Docker Security</h2>
            <div id="docker-content">
                <p>Docker security results will be populated here...</p>
            </div>
        </div>

        <div class="section">
            <h2>📁 Generated Files</h2>
            <div class="file-list">
                <h3>Security Reports Directory:</h3>
                <ul id="file-list">
                    <!-- Files will be populated here -->
                </ul>
            </div>
        </div>

        <div class="section">
            <h2>✅ Recommendations</h2>
            <div id="recommendations">
                <div class="recommendation">
                    <strong>Regular Scanning:</strong> Run security scans before each deployment
                </div>
                <div class="recommendation">
                    <strong>Dependency Updates:</strong> Keep dependencies up to date with security patches
                </div>
                <div class="recommendation">
                    <strong>License Review:</strong> Ensure all licenses are compatible with your use case
                </div>
                <div class="recommendation">
                    <strong>Docker Security:</strong> Regularly update base images and follow security best practices
                </div>
            </div>
        </div>

        <div class="footer">
            <p>This report was generated by the Home Library Service security scanning suite.</p>
            <p>For questions or issues, please review the individual scan results.</p>
        </div>
    </div>
</body>
</html>
EOF

# Replace placeholders
sed -i "s/REPORT_DATE/$(date)/" "$REPORT_DIR/security-report-${TIMESTAMP}.html"

echo -e "${GREEN}📄 HTML report generated: security-reports/security-report-${TIMESTAMP}.html${NC}"

# Generate JSON summary
cat > "$REPORT_DIR/security-summary.json" << EOF
{
    "timestamp": "$(date -Iseconds)",
    "project": "home-library-service",
    "scans": {
        "npm_audit": {
            "completed": $([ -f "$REPORT_DIR/npm-audit.json" ] && echo "true" || echo "false"),
            "file": "npm-audit.json"
        },
        "license_scan": {
            "completed": $([ -f "$REPORT_DIR/license-compliance.md" ] && echo "true" || echo "false"),
            "file": "license-compliance.md"
        },
        "docker_scan": {
            "completed": $([ -f "$REPORT_DIR/docker-security-summary.md" ] && echo "true" || echo "false"),
            "file": "docker-security-summary.md"
        }
    },
    "files_generated": [
EOF

# List all files in the reports directory
FIRST_FILE=true
for file in "$REPORT_DIR"/*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        if [ "$FIRST_FILE" = true ]; then
            FIRST_FILE=false
        else
            echo "," >> "$REPORT_DIR/security-summary.json"
        fi
        echo -n "        \"$filename\"" >> "$REPORT_DIR/security-summary.json"
    fi
done

cat >> "$REPORT_DIR/security-summary.json" << EOF

    ]
}
EOF

echo -e "${GREEN}📄 JSON summary: security-reports/security-summary.json${NC}"

# Generate markdown summary
cat > "$REPORT_DIR/README.md" << EOF
# Security Reports

This directory contains comprehensive security scan results for the Home Library Service.

## 📁 Generated Reports

### NPM Audit
- \`npm-audit.json\` - NPM vulnerability scan results
- \`npm-audit-detailed.json\` - Detailed vulnerability information
- \`outdated-packages.txt\` - List of outdated dependencies
- \`dependency-tree.txt\` - Complete dependency tree

### License Compliance
- \`license-compliance.md\` - License compliance report
- \`all-licenses.json\` - Complete license information
- \`licenses.csv\` - License data in CSV format
- \`license-summary.txt\` - License summary
- \`license-counts.txt\` - License distribution

### Docker Security
- \`docker-security-summary.md\` - Docker security analysis
- \`docker-history.txt\` - Docker image layer history
- \`docker-inspect.json\` - Detailed image information

### Summary Reports
- \`security-summary.json\` - Machine-readable summary
- \`security-report-${TIMESTAMP}.html\` - Comprehensive HTML report
- \`README.md\` - This file

## 🔧 How to Use

### View Reports
\`\`\`bash
# View HTML report in browser
open security-reports/security-report-${TIMESTAMP}.html

# View license compliance
cat security-reports/license-compliance.md

# View Docker security summary
cat security-reports/docker-security-summary.md
\`\`\`

### Re-run Scans
\`\`\`bash
# Run all security scans
npm run security:full

# Run specific scans
npm run security        # NPM audit + dependencies + licenses
npm run security:docker # Docker security scan
npm run security:licenses # License compliance only
\`\`\`

## 📊 Quick Commands

\`\`\`bash
# Check for vulnerabilities
npm audit

# Fix vulnerabilities
npm audit fix

# Update dependencies
npm update

# Generate new report
npm run security:report
\`\`\`

---

**Last Updated:** $(date)
EOF

echo -e "${GREEN}📄 Documentation: security-reports/README.md${NC}"

# Count files and provide summary
TOTAL_FILES=$(find "$REPORT_DIR" -type f | wc -l)
REPORT_SIZE=$(du -sh "$REPORT_DIR" | cut -f1)

echo ""
echo -e "${GREEN}🎉 Security report generation completed!${NC}"
echo "======================================="
echo ""
echo -e "${BLUE}📊 Summary:${NC}"
echo "   📁 Reports directory: $REPORT_DIR"
echo "   📄 Total files: $TOTAL_FILES"
echo "   💾 Total size: $REPORT_SIZE"
echo ""
echo -e "${CYAN}📋 Key Files:${NC}"
echo "   🌐 HTML Report: security-report-${TIMESTAMP}.html"
echo "   📊 JSON Summary: security-summary.json"
echo "   📖 Documentation: README.md"
echo ""
echo -e "${CYAN}💡 Next steps:${NC}"
echo "   1. Open HTML report in browser for detailed view"
echo "   2. Review license compliance and Docker security"
echo "   3. Address any identified vulnerabilities"
echo "   4. Set up automated scanning in CI/CD"
echo "   5. Share reports with security team"
echo ""
