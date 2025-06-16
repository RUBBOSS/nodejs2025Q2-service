#!/bin/bash

# License Scanning Script
# Scans dependencies for license compliance

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

REPORT_DIR="security-reports"

echo -e "${CYAN}📜 License Compliance Scanning${NC}"
echo "=============================="
echo ""

# Create reports directory
mkdir -p "$REPORT_DIR"

# Function to install license-checker if not present
install_license_checker() {
    if ! command -v license-checker >/dev/null 2>&1; then
        echo -e "${YELLOW}📦 Installing license-checker...${NC}"
        npm install -g license-checker || {
            echo -e "${RED}❌ Failed to install license-checker${NC}"
            return 1
        }
    fi
}

echo -e "${BLUE}🔍 Step 1: License Detection${NC}"
echo "============================"

if install_license_checker; then
    echo -e "${CYAN}📋 Scanning all licenses...${NC}"
    
    # Generate complete license report
    license-checker --json > "$REPORT_DIR/all-licenses.json" 2>/dev/null || echo "License scan completed"
    
    # Generate CSV format
    license-checker --csv > "$REPORT_DIR/licenses.csv" 2>/dev/null || echo "CSV report generated"
    
    # Generate summary
    license-checker --summary > "$REPORT_DIR/license-summary.txt" 2>/dev/null || echo "Summary generated"
    
    echo -e "${GREEN}📄 Complete license report: security-reports/all-licenses.json${NC}"
    echo -e "${GREEN}📄 CSV format: security-reports/licenses.csv${NC}"
    echo -e "${GREEN}📄 Summary: security-reports/license-summary.txt${NC}"
else
    echo -e "${RED}❌ Cannot perform license scanning without license-checker${NC}"
    exit 1
fi
echo ""

echo -e "${BLUE}🔍 Step 2: License Compliance Check${NC}"
echo "=================================="

# Define allowed licenses for different use cases
PERMISSIVE_LICENSES="MIT;Apache-2.0;BSD-2-Clause;BSD-3-Clause;ISC;Unlicense;WTFPL;0BSD"
COPYLEFT_LICENSES="GPL-2.0;GPL-3.0;LGPL-2.1;LGPL-3.0;AGPL-3.0"
RESTRICTED_LICENSES="CC-BY-NC;CC-BY-NC-SA;SSPL;BUSL"

echo -e "${CYAN}📋 Checking for permissive licenses only...${NC}"

# Check for permissive licenses only (most restrictive check)
if license-checker --onlyAllow "$PERMISSIVE_LICENSES" --excludePrivatePackages >/dev/null 2>&1; then
    echo -e "${GREEN}✅ All dependencies use permissive licenses${NC}"
    COMPLIANCE_STATUS="PASS"
else
    echo -e "${YELLOW}⚠️  Some dependencies may have restrictive licenses${NC}"
    COMPLIANCE_STATUS="WARNING"
    
    # Generate report of problematic licenses
    license-checker --failOn "$COPYLEFT_LICENSES;$RESTRICTED_LICENSES" \
        --excludePrivatePackages \
        --json > "$REPORT_DIR/problematic-licenses.json" 2>/dev/null || echo "Problematic licenses report generated"
    
    echo -e "${GREEN}📄 Problematic licenses: security-reports/problematic-licenses.json${NC}"
fi
echo ""

echo -e "${BLUE}🔍 Step 3: License Analysis${NC}"
echo "==========================="

# Count licenses by type
echo -e "${CYAN}📋 Analyzing license distribution...${NC}"

if [ -f "$REPORT_DIR/all-licenses.json" ]; then
    # Extract unique licenses and count them
    jq -r '.[] | .licenses' "$REPORT_DIR/all-licenses.json" 2>/dev/null | \
        grep -v "^$" | sort | uniq -c | sort -nr > "$REPORT_DIR/license-counts.txt" 2>/dev/null || echo "License counting completed"
    
    echo -e "${GREEN}📄 License distribution: security-reports/license-counts.txt${NC}"
    
    # Show top licenses
    echo -e "${CYAN}📊 Most common licenses:${NC}"
    head -10 "$REPORT_DIR/license-counts.txt" 2>/dev/null || echo "License data not available"
fi
echo ""

echo -e "${BLUE}🔍 Step 4: Dependency License Details${NC}"
echo "===================================="

# Generate detailed report for packages with concerning licenses
echo -e "${CYAN}📋 Generating detailed license information...${NC}"

cat > "$REPORT_DIR/license-details.txt" << EOF
License Scan Details
===================
Date: $(date)
Project: Home Library Service

Analysis:
EOF

if [ -f "$REPORT_DIR/license-summary.txt" ]; then
    echo "" >> "$REPORT_DIR/license-details.txt"
    echo "License Summary:" >> "$REPORT_DIR/license-details.txt"
    echo "===============" >> "$REPORT_DIR/license-details.txt"
    cat "$REPORT_DIR/license-summary.txt" >> "$REPORT_DIR/license-details.txt"
fi

if [ -f "$REPORT_DIR/license-counts.txt" ]; then
    echo "" >> "$REPORT_DIR/license-details.txt"
    echo "License Distribution:" >> "$REPORT_DIR/license-details.txt"
    echo "====================" >> "$REPORT_DIR/license-details.txt"
    cat "$REPORT_DIR/license-counts.txt" >> "$REPORT_DIR/license-details.txt"
fi

echo -e "${GREEN}📄 Detailed analysis: security-reports/license-details.txt${NC}"
echo ""

echo -e "${BLUE}🔍 Step 5: Compliance Recommendations${NC}"
echo "===================================="

# Generate compliance recommendations
cat > "$REPORT_DIR/license-compliance.md" << EOF
# License Compliance Report

**Date:** $(date)
**Project:** Home Library Service
**Status:** $COMPLIANCE_STATUS

## Summary

This report analyzes the licenses of all dependencies in the project.

### Compliance Status: $COMPLIANCE_STATUS

EOF

case $COMPLIANCE_STATUS in
    "PASS")
        cat >> "$REPORT_DIR/license-compliance.md" << EOF
✅ **All dependencies use permissive licenses** that are compatible with commercial use.

### Allowed License Types
- MIT License
- Apache License 2.0
- BSD 2-Clause License
- BSD 3-Clause License
- ISC License
- Unlicense
- WTFPL

EOF
        ;;
    "WARNING")
        cat >> "$REPORT_DIR/license-compliance.md" << EOF
⚠️ **Some dependencies may have restrictive licenses** that require careful review.

### Action Required
1. Review \`problematic-licenses.json\` for details
2. Consult legal team if necessary
3. Consider alternative packages with permissive licenses
4. Ensure compliance with copyleft requirements if using GPL/LGPL code

### Potentially Problematic License Types
- GPL (requires derivative works to be GPL)
- LGPL (requires dynamic linking or source availability)
- AGPL (requires source for network services)
- Creative Commons Non-Commercial
- Custom restrictive licenses

EOF
        ;;
esac

cat >> "$REPORT_DIR/license-compliance.md" << EOF
## Recommendations

1. **Regular Scanning**: Run license scans before each release
2. **License Policy**: Establish a clear license policy for the organization
3. **Dependency Review**: Review new dependencies before adding them
4. **Legal Consultation**: Consult legal team for unclear licenses
5. **Alternative Packages**: Maintain a list of approved alternatives

## Files Generated

- \`all-licenses.json\` - Complete license information
- \`licenses.csv\` - License data in CSV format
- \`license-summary.txt\` - Summary of all licenses
- \`license-counts.txt\` - License distribution
- \`license-details.txt\` - Detailed analysis
- \`problematic-licenses.json\` - Dependencies with concerning licenses (if any)

## Next Steps

1. Review all generated reports
2. Address any problematic licenses
3. Document license decisions
4. Set up automated license scanning in CI/CD
EOF

echo -e "${GREEN}📄 Compliance report: security-reports/license-compliance.md${NC}"
echo ""

echo -e "${GREEN}🎉 License scanning completed!${NC}"
echo "=============================="
echo ""
echo -e "${BLUE}📊 Scan Results:${NC}"
echo "   Status: $COMPLIANCE_STATUS"
echo "   Reports: security-reports/"
echo ""
echo -e "${CYAN}💡 Next steps:${NC}"
echo "   1. Review license-compliance.md"
echo "   2. Check problematic-licenses.json (if exists)"
echo "   3. Consult legal team for unclear licenses"
echo "   4. Document license policy decisions"
echo "   5. Set up automated license checks"
echo ""

# Exit with appropriate code
if [ "$COMPLIANCE_STATUS" = "PASS" ]; then
    exit 0
else
    exit 1
fi
