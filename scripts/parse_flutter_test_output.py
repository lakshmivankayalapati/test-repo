#!/usr/bin/env python3
"""
Parse Flutter test output and generate markdown reports
"""

import json
import sys
import os
from datetime import datetime

def parse_flutter_test_output(input_file, output_file):
    """Parse Flutter test output and generate markdown report"""
    
    try:
        with open(input_file, 'r') as f:
            test_data = json.load(f)
    except FileNotFoundError:
        print(f"Error: Test output file {input_file} not found")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON in {input_file}")
        sys.exit(1)
    
    # Extract test results
    passed_tests = 0
    failed_tests = 0
    total_tests = 0
    failure_details = []
    
    for test in test_data:
        if test.get('type') == 'testDone':
            total_tests += 1
            if test.get('result') == 'success':
                passed_tests += 1
            else:
                failed_tests += 1
                failure_details.append({
                    'name': test.get('name', 'Unknown'),
                    'error': test.get('error', 'Unknown error')
                })
    
    # Calculate success rate
    success_rate = (passed_tests / total_tests * 100) if total_tests > 0 else 0
    overall_status = "PASSED" if failed_tests == 0 else "FAILED"
    
    # Generate markdown report
    report = f"""# Flutter Test Report

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
        for failure in failure_details:
            report += f"- **{failure['name']}**: {failure['error']}\n"
    else:
        report += "No tests failed.\n"
    
    report += f"""
## 📅 Report Generated
Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

---
*Report generated automatically by Flutter CI Pipeline*
"""
    
    # Write report to file
    with open(output_file, 'w') as f:
        f.write(report)
    
    print(f"✅ Generated test report: {output_file}")
    print(f"📊 Results: {passed_tests}/{total_tests} tests passed ({success_rate:.1f}%)")
    
    # Set GitHub outputs
    print(f"::set-output name=status::{overall_status}")
    print(f"::set-output name=passed_tests::{passed_tests}")
    print(f"::set-output name=failed_tests::{failed_tests}")
    print(f"::set-output name=total_tests::{total_tests}")
    print(f"::set-output name=success_rate::{success_rate:.1f}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 parse_flutter_test_output.py <input_file> <output_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    parse_flutter_test_output(input_file, output_file)
