# License Compliance Report

**Date:** Sun, Jun  8, 2025 12:27:02 PM
**Project:** Home Library Service
**Status:** WARNING

## Summary

This report analyzes the licenses of all dependencies in the project.

### Compliance Status: WARNING

⚠️ **Some dependencies may have restrictive licenses** that require careful review.

### Action Required
1. Review `problematic-licenses.json` for details
2. Consult legal team if necessary
3. Consider alternative packages with permissive licenses
4. Ensure compliance with copyleft requirements if using GPL/LGPL code

### Potentially Problematic License Types
- GPL (requires derivative works to be GPL)
- LGPL (requires dynamic linking or source availability)
- AGPL (requires source for network services)
- Creative Commons Non-Commercial
- Custom restrictive licenses

## Recommendations

1. **Regular Scanning**: Run license scans before each release
2. **License Policy**: Establish a clear license policy for the organization
3. **Dependency Review**: Review new dependencies before adding them
4. **Legal Consultation**: Consult legal team for unclear licenses
5. **Alternative Packages**: Maintain a list of approved alternatives

## Files Generated

- `all-licenses.json` - Complete license information
- `licenses.csv` - License data in CSV format
- `license-summary.txt` - Summary of all licenses
- `license-counts.txt` - License distribution
- `license-details.txt` - Detailed analysis
- `problematic-licenses.json` - Dependencies with concerning licenses (if any)

## Next Steps

1. Review all generated reports
2. Address any problematic licenses
3. Document license decisions
4. Set up automated license scanning in CI/CD
