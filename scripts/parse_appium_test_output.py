#!/usr/bin/env python3
"""
Parse Appium test output and generate markdown reports
"""

import json
import sys
import os
from datetime import datetime

def parse_appium_test_output(input_file, output_file):
    """Parse Appium test output and generate markdown report"""
    
    try:
        with open(input_file, 'r') as f:
            test_data = json.load(f)
    except FileNotFoundError:
        print(f"Error: Appium test output file {input_file} not found")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON in {input_file}")
        sys.exit(1)
    
    # Extract test results
    passed_tests = test_data.get('passed_tests', 0)
    failed_tests = test_data.get('failed_tests', 0)
    total_tests = test_data.get('total_tests', 0)
    test_details = test_data.get('test_details', [])
    
    # Calculate success rate
    success_rate = (passed_tests / total_tests * 100) if total_tests > 0 else 0
    overall_status = "PASSED" if failed_tests == 0 else "FAILED"
    
    # Generate markdown report
    report = f"""# Appium LambdaTest Integration Report

## 📊 Test Summary
- **Overall Status**: {'✅ PASSED' if overall_status == 'PASSED' else '❌ FAILED'}
- **Total Tests**: {total_tests}
- **Passed Tests**: {passed_tests}
- **Failed Tests**: {failed_tests}
- **Success Rate**: {success_rate:.1f}%

## 📋 Test Results

### ✅ Passed Tests
{passed_tests} tests passed successfully.

### ❌ Failed Tests
"""
    
    if failed_tests > 0:
        for test in test_details:
            if test.get('status') == 'failed':
                report += f"- **{test.get('name', 'Unknown')}**: {test.get('error', 'Unknown error')}\n"
    else:
        report += "No tests failed.\n"
    
    # Add device information if available
    device_info = test_data.get('device_info', {})
    if device_info:
        report += f"""
## 📱 Device Information
- **Platform**: {device_info.get('platform', 'Unknown')}
- **Device**: {device_info.get('device', 'Unknown')}
- **OS Version**: {device_info.get('os_version', 'Unknown')}
"""
    
    report += f"""
## 📅 Report Generated
Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

---
*Report generated automatically by Appium CI Pipeline*
"""
    
    # Write report to file
    with open(output_file, 'w') as f:
        f.write(report)
    
    print(f"✅ Generated Appium test report: {output_file}")
    print(f"📊 Results: {passed_tests}/{total_tests} tests passed ({success_rate:.1f}%)")
    
    # Set GitHub outputs
    print(f"::set-output name=status::{overall_status}")
    print(f"::set-output name=passed_tests::{passed_tests}")
    print(f"::set-output name=failed_tests::{failed_tests}")
    print(f"::set-output name=total_tests::{total_tests}")
    print(f"::set-output name=success_rate::{success_rate:.1f}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 parse_appium_test_output.py <input_file> <output_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    parse_appium_test_output(input_file, output_file)
