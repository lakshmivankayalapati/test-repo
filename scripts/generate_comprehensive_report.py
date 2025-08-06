#!/usr/bin/env python3
"""
Generate comprehensive test report combining all test results
"""

import json
import sys
import os
import glob
from datetime import datetime

def load_test_results(test_reports_dir):
    """Load test results from downloaded artifacts"""
    results = {
        'unit_tests': {'status': 'unknown', 'passed': 0, 'failed': 0, 'total': 0},
        'widget_tests': {'status': 'unknown', 'passed': 0, 'failed': 0, 'total': 0},
        'accessibility_tests': {'status': 'unknown', 'passed': 0, 'failed': 0, 'total': 0},
        'golden_tests': {'status': 'unknown', 'passed': 0, 'failed': 0, 'total': 0},
        'appium_tests': {'status': 'unknown', 'passed': 0, 'failed': 0, 'total': 0},
        'performance_tests': {'status': 'unknown', 'passed': 0, 'failed': 0, 'total': 0}
    }
    
    # Try to load unit test results
    try:
        unit_files = glob.glob(f"{test_reports_dir}/**/unit-test-results/test_output.json", recursive=True)
        if unit_files:
            with open(unit_files[0], 'r') as f:
                data = json.load(f)
                passed = sum(1 for test in data if test.get('type') == 'testDone' and test.get('result') == 'success')
                failed = sum(1 for test in data if test.get('type') == 'testDone' and test.get('result') != 'success')
                total = passed + failed
                results['unit_tests'] = {
                    'status': 'PASSED' if failed == 0 else 'FAILED',
                    'passed': passed,
                    'failed': failed,
                    'total': total
                }
    except Exception as e:
        print(f"Warning: Could not load unit test results: {e}")
    
    # Try to load widget test results
    try:
        widget_files = glob.glob(f"{test_reports_dir}/**/widget-test-results/test_output.json", recursive=True)
        if widget_files:
            with open(widget_files[0], 'r') as f:
                data = json.load(f)
                passed = sum(1 for test in data if test.get('type') == 'testDone' and test.get('result') == 'success')
                failed = sum(1 for test in data if test.get('type') == 'testDone' and test.get('result') != 'success')
                total = passed + failed
                results['widget_tests'] = {
                    'status': 'PASSED' if failed == 0 else 'FAILED',
                    'passed': passed,
                    'failed': failed,
                    'total': total
                }
    except Exception as e:
        print(f"Warning: Could not load widget test results: {e}")
    
    # Try to load accessibility test results
    try:
        accessibility_files = glob.glob(f"{test_reports_dir}/**/accessibility-test-results/test_output.json", recursive=True)
        if accessibility_files:
            with open(accessibility_files[0], 'r') as f:
                data = json.load(f)
                passed = sum(1 for test in data if test.get('type') == 'testDone' and test.get('result') == 'success')
                failed = sum(1 for test in data if test.get('type') == 'testDone' and test.get('result') != 'success')
                total = passed + failed
                results['accessibility_tests'] = {
                    'status': 'PASSED' if failed == 0 else 'FAILED',
                    'passed': passed,
                    'failed': failed,
                    'total': total
                }
    except Exception as e:
        print(f"Warning: Could not load accessibility test results: {e}")
    
    # Try to load golden test results
    try:
        golden_files = glob.glob(f"{test_reports_dir}/**/golden-test-results/test_output.json", recursive=True)
        if golden_files:
            with open(golden_files[0], 'r') as f:
                data = json.load(f)
                passed = sum(1 for test in data if test.get('type') == 'testDone' and test.get('result') == 'success')
                failed = sum(1 for test in data if test.get('type') == 'testDone' and test.get('result') != 'success')
                total = passed + failed
                results['golden_tests'] = {
                    'status': 'PASSED' if failed == 0 else 'FAILED',
                    'passed': passed,
                    'failed': failed,
                    'total': total
                }
    except Exception as e:
        print(f"Warning: Could not load golden test results: {e}")
    
    # Try to load appium test results
    try:
        appium_files = glob.glob(f"{test_reports_dir}/**/appium-test-results/appium_test_results.json", recursive=True)
        if appium_files:
            with open(appium_files[0], 'r') as f:
                data = json.load(f)
                results['appium_tests'] = {
                    'status': data.get('status', 'FAILED'),
                    'passed': data.get('passed_tests', 0),
                    'failed': data.get('failed_tests', 0),
                    'total': data.get('total_tests', 0)
                }
    except Exception as e:
        print(f"Warning: Could not load appium test results: {e}")
    
    # Try to load performance test results
    try:
        perf_files = glob.glob(f"{test_reports_dir}/**/performance-test-results/performance_test_results.json", recursive=True)
        if perf_files:
            with open(perf_files[0], 'r') as f:
                data = json.load(f)
                results['performance_tests'] = {
                    'status': data.get('status', 'FAILED'),
                    'passed': data.get('passed_tests', 0),
                    'failed': data.get('failed_tests', 0),
                    'total': data.get('total_tests', 0)
                }
    except Exception as e:
        print(f"Warning: Could not load performance test results: {e}")
    
    return results

def generate_comprehensive_report(test_results, output_file):
    """Generate comprehensive test report"""
    
    # Calculate overall statistics
    total_passed = sum(result['passed'] for result in test_results.values())
    total_failed = sum(result['failed'] for result in test_results.values())
    total_tests = sum(result['total'] for result in test_results.values())
    overall_status = "PASSED" if total_failed == 0 else "FAILED"
    success_rate = (total_passed / total_tests * 100) if total_tests > 0 else 0
    
    # Generate report
    report = f"""# 🧪 Comprehensive Test Report

## 📊 Executive Summary
| Metric | Value |
|--------|-------|
| **Overall Status** | {'✅ PASSED' if overall_status == 'PASSED' else '❌ FAILED'} |
| **Total Tests** | {total_tests} |
| **Passed Tests** | {total_passed} |
| **Failed Tests** | {total_failed} |
| **Success Rate** | {success_rate:.1f}% |

## 📋 Detailed Results by Test Suite

### 🔧 Unit Tests
- **Status**: {'✅ PASSED' if test_results['unit_tests']['status'] == 'PASSED' else '❌ FAILED'}
- **Tests**: {test_results['unit_tests']['passed']}/{test_results['unit_tests']['total']} passed
- **Failed Tests**: {test_results['unit_tests']['failed']}

### 🎨 Widget Tests
- **Status**: {'✅ PASSED' if test_results['widget_tests']['status'] == 'PASSED' else '❌ FAILED'}
- **Tests**: {test_results['widget_tests']['passed']}/{test_results['widget_tests']['total']} passed
- **Failed Tests**: {test_results['widget_tests']['failed']}

### ♿ Accessibility Tests
- **Status**: {'✅ PASSED' if test_results['accessibility_tests']['status'] == 'PASSED' else '❌ FAILED'}
- **Tests**: {test_results['accessibility_tests']['passed']}/{test_results['accessibility_tests']['total']} passed
- **Failed Tests**: {test_results['accessibility_tests']['failed']}

### 📸 Golden Tests
- **Status**: {'✅ PASSED' if test_results['golden_tests']['status'] == 'PASSED' else '❌ FAILED'}
- **Tests**: {test_results['golden_tests']['passed']}/{test_results['golden_tests']['total']} passed
- **Failed Tests**: {test_results['golden_tests']['failed']}

### 🤖 Appium LambdaTest
- **Status**: {'✅ PASSED' if test_results['appium_tests']['status'] == 'PASSED' else '❌ FAILED'}
- **Tests**: {test_results['appium_tests']['passed']}/{test_results['appium_tests']['total']} passed
- **Failed Tests**: {test_results['appium_tests']['failed']}

### ⚡ Performance Metrics Tests
- **Status**: {'✅ PASSED' if test_results['performance_tests']['status'] == 'PASSED' else '❌ FAILED'}
- **Tests**: {test_results['performance_tests']['passed']}/{test_results['performance_tests']['total']} passed
- **Failed Tests**: {test_results['performance_tests']['failed']}

## 🔍 Failure Analysis
"""
    
    if total_failed == 0:
        report += "✅ All Test Suites Passed!\n"
    else:
        failed_suites = [name for name, result in test_results.items() if result['failed'] > 0]
        report += f"❌ Failed Test Suites: {', '.join(failed_suites)}\n"
    
    report += f"""
## 📁 Test Artifacts
The following test artifacts are available for download:

- **Unit Test Results**: Available in the workflow artifacts
- **Widget Test Results**: Available in the workflow artifacts
- **Accessibility Test Results**: Available in the workflow artifacts
- **Golden Test Results**: Available in the workflow artifacts (includes golden images)
- **Appium LambdaTest Results**: Available in the workflow artifacts
- **Performance Test Results**: Available in the workflow artifacts

## 🚀 Next Steps
"""
    
    if overall_status == "PASSED":
        report += "✅ All tests passed! The code is ready for merge.\n"
    else:
        report += "❌ Some tests failed. Please review the failed test suites and fix the issues before merging.\n"
    
    report += f"""
---
*Report generated automatically by GitHub Actions CI Pipeline*
*Generated on: {datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')}*
"""
    
    # Write report to file
    with open(output_file, 'w') as f:
        f.write(report)
    
    print(f"✅ Generated comprehensive test report: {output_file}")
    print(f"📊 Overall Results: {total_passed}/{total_tests} tests passed ({success_rate:.1f}%)")
    
    # Set GitHub outputs
    print(f"::set-output name=overall_status::{overall_status}")
    print(f"::set-output name=total_passed::{total_passed}")
    print(f"::set-output name=total_failed::{total_failed}")
    print(f"::set-output name=total_tests::{total_tests}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 generate_comprehensive_report.py <test_reports_dir> <output_file>")
        sys.exit(1)
    
    test_reports_dir = sys.argv[1]
    output_file = sys.argv[2]
    
    # Load test results
    test_results = load_test_results(test_reports_dir)
    
    # Generate comprehensive report
    generate_comprehensive_report(test_results, output_file)
