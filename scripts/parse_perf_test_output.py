#!/usr/bin/env python3
"""
Parse performance test output and generate markdown reports
"""

import json
import sys
import os
from datetime import datetime

def parse_perf_test_output(input_file, output_file):
    """Parse performance test output and generate markdown report"""
    
    try:
        with open(input_file, 'r') as f:
            test_data = json.load(f)
    except FileNotFoundError:
        print(f"Error: Performance test output file {input_file} not found")
        sys.exit(1)
    except json.JSONDecodeError:
        print(f"Error: Invalid JSON in {input_file}")
        sys.exit(1)
    
    # Extract test results
    status = test_data.get('status', 'failed')
    passed_tests = test_data.get('passed_tests', 0)
    failed_tests = test_data.get('failed_tests', 0)
    total_tests = test_data.get('total_tests', 0)
    
    # Extract performance metrics
    test_info = test_data.get('test_info', {})
    performance_metrics = test_data.get('performance_metrics', {})
    
    # Calculate success rate
    success_rate = (passed_tests / total_tests * 100) if total_tests > 0 else 0
    overall_status = "PASSED" if status == "passed" else "FAILED"
    
    # Generate markdown report
    report = f"""# Performance Metrics Test Report

## 📊 Test Summary
- **Overall Status**: {'✅ PASSED' if overall_status == 'PASSED' else '❌ FAILED'}
- **Total Tests**: {total_tests}
- **Passed Tests**: {passed_tests}
- **Failed Tests**: {failed_tests}
- **Success Rate**: {success_rate:.1f}%

## 🚀 Performance Metrics

### 📱 Launch Performance
"""
    
    if test_info:
        report += f"""- **Target Launches**: {test_info.get('target_launches', 'N/A')}
- **Successful Launches**: {test_info.get('successful_launches', 'N/A')}
- **Failed Launches**: {test_info.get('failed_launches', 'N/A')}
- **Success Rate**: {test_info.get('success_rate', 'N/A')}%
- **Average Launch Time**: {test_info.get('avg_launch_time', 'N/A')}ms
"""
    
    if performance_metrics:
        report += f"""
### ⚡ Performance Metrics
- **Cold Startup Time**: {performance_metrics.get('cold_startup_time', 'N/A')}ms
- **Hot Startup Time**: {performance_metrics.get('hot_startup_time', 'N/A')}ms
- **Max CPU Usage**: {performance_metrics.get('max_cpu', 'N/A')}%
- **Average CPU Usage**: {performance_metrics.get('avg_cpu', 'N/A')}%
- **Max Memory Usage**: {performance_metrics.get('max_memory', 'N/A')}MB
- **Average Memory Usage**: {performance_metrics.get('avg_memory', 'N/A')}MB
- **Average Frame Rate**: {performance_metrics.get('avg_frame_rate', 'N/A')} FPS
- **ANR Count**: {performance_metrics.get('anr_count', 'N/A')}
- **App Crashes**: {performance_metrics.get('app_crashes', 'N/A')}
"""
    
    # Add failure reasons if any
    failure_reasons = test_data.get('failure_reasons', [])
    if failure_reasons:
        report += f"""
## ❌ Failure Analysis
"""
        for reason in failure_reasons:
            report += f"- {reason}\n"
    
    report += f"""
## 📅 Report Generated
Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}

---
*Report generated automatically by Performance CI Pipeline*
"""
    
    # Write report to file
    with open(output_file, 'w') as f:
        f.write(report)
    
    print(f"✅ Generated performance test report: {output_file}")
    print(f"📊 Results: {passed_tests}/{total_tests} tests passed ({success_rate:.1f}%)")
    
    # Set GitHub outputs
    print(f"::set-output name=status::{overall_status}")
    print(f"::set-output name=passed_tests::{passed_tests}")
    print(f"::set-output name=failed_tests::{failed_tests}")
    print(f"::set-output name=total_tests::{total_tests}")
    print(f"::set-output name=success_rate::{success_rate:.1f}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 parse_perf_test_output.py <input_file> <output_file>")
        sys.exit(1)
    
    input_file = sys.argv[1]
    output_file = sys.argv[2]
    
    parse_perf_test_output(input_file, output_file)
