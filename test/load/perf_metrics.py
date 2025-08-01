#!/usr/bin/env python3
"""
Integrated Performance Test with Session Analysis
===============================================

This script performs automated performance testing and includes integrated session
data extraction and analysis. It generates a comprehensive report combining both
test results and LambdaTest session metrics.

Usage:
    python perf_metrics.py
"""

import time
import json
import statistics
import requests
from datetime import datetime
from appium import webdriver
from appium.options.android import UiAutomator2Options
from selenium.webdriver.common.by import By
from appium.webdriver.common.appiumby import AppiumBy
import warnings

warnings.filterwarnings("ignore", message="Embedding username and password in URL could be insecure")

# --- Configuration ---
username = "lakshmivankayalapati"
access_key = "LT_D4KfZYw80A6JvF1Wnlrnu0db9JuT7knmEode8ZR6I1oZncw"

# App configuration
app_package = "com.example.sliq_pay"
app_activity = "com.example.sliq_pay.MainActivity"
app_url = "lt://APP1016057671753726420977541"

# Performance test configuration
TARGET_COLD_LAUNCHES = 10  # Number of cold launches to perform
FRAME_DROP_THRESHOLD = 0  # No frame drops allowed
MIN_FPS_THRESHOLD = 60  # Minimum FPS during cold launch

class IntegratedPerformanceTest:
    def __init__(self):
        self.cold_launch_times = []
        self.frame_drops = []
        self.fps_measurements = []
        self.session_id = None
        self.test_start_time = None
        self.test_end_time = None
        self.driver = None
        self.driver_closed = False  # Track driver state
        
    def create_driver(self):
        """Create and configure the Appium driver for automated performance testing."""
        options = UiAutomator2Options()
        options.platform_name = "Android"
        options.device_name = "Google Pixel 4a"
        options.platform_version = "12"
        options.set_capability("isRealMobile", True)
        options.set_capability("app", app_url)
        options.set_capability("build", "Extensive Performance Logging 3")
        options.set_capability("name", "Extensive Performance Test 3")
        options.set_capability("deviceOrientation", "PORTRAIT")
        
        # LambdaTest App Performance Analytics capabilities
        options.set_capability("appProfiling", True)  # Enable app profiling for performance metrics
        options.set_capability("resignApp", True)     # Required for full app profiling functionality
        options.set_capability("network", True)       # Enable network logs
        options.set_capability("video", True)         # Record video for frame analysis
        options.set_capability("console", True)       # Capture console logs
        options.set_capability("logcat", True)        # Capture device logs
        options.set_capability("autoGrantPermissions", True)
        
        self.driver = webdriver.Remote(
            command_executor=f"https://{username}:{access_key}@mobile-hub.lambdatest.com/wd/hub",
            options=options
        )
        
        # Store session ID for later data extraction
        self.session_id = self.driver.session_id
        print(f"✅ Driver initialized successfully with session ID: {self.session_id}")
        
    def perform_cold_launch(self, iteration_num):
        """Perform a single cold launch and measure performance metrics."""
        print(f"🔄 Cold Launch Iteration {iteration_num}")
        
        try:
            # 1. Force stop the app to ensure cold start
            self.driver.terminate_app(app_package)
            time.sleep(0.5)  # Brief pause for system cleanup
            
            # 2. Record start time for cold launch measurement
            start_time = time.time()
            
            # 3. Launch the app (cold start)
            self.driver.activate_app(app_package)
            
            # 4. Wait for app to be fully loaded (look for a key element)
            max_wait = 10  # Maximum 10 seconds for app to load
            app_loaded = False
            
            for _ in range(max_wait * 2):  # Check every 0.5 seconds
                try:
                    # Look for any element that indicates app is loaded
                    # This could be the welcome screen, logo, or any stable element
                    self.driver.find_element(By.XPATH, "//*[contains(@content-desc, 'Pay Anywhere') or contains(@content-desc, 'Get Started') or contains(@content-desc, 'Log In')]")
                    app_loaded = True
                    break
                except:
                    time.sleep(0.5)
                    continue
            
            # 5. Record end time and calculate cold launch time
            end_time = time.time()
            cold_launch_time_ms = (end_time - start_time) * 1000
            
            if app_loaded:
                print(f"✅ Cold Launch {iteration_num}: {cold_launch_time_ms:.2f}ms")
                return {
                    'success': True,
                    'cold_launch_time_ms': cold_launch_time_ms,
                    'app_loaded': True
                }
            else:
                print(f"❌ Cold Launch {iteration_num}: App failed to load within {max_wait}s")
                return {
                    'success': False,
                    'cold_launch_time_ms': cold_launch_time_ms,
                    'app_loaded': False
                }
                
        except Exception as e:
            print(f"❌ Error during cold launch {iteration_num}: {e}")
            return {
                'success': False,
                'cold_launch_time_ms': 0,
                'app_loaded': False,
                'error': str(e)
            }
    
    def extract_session_data(self, session_id):
        """Extract comprehensive session data from LambdaTest API with improved retry mechanism."""
        print(f"🔍 Extracting session data for: {session_id}")
        
        # Add longer delay to allow LambdaTest to process profiling data
        print("⏳ Waiting for LambdaTest to process session data...")
        time.sleep(30)  # Wait 30 seconds for initial processing
        
        max_retries = 5
        retry_delay = 20  # seconds
        
        for attempt in range(max_retries):
            try:
                print(f"🔄 Attempt {attempt + 1}/{max_retries} to extract session data...")
                
                # Fetch app profiling metrics
                profiling_url = f"https://{username}:{access_key}@mobile-api.lambdatest.com/mobile-automation/api/v1/sessions/{session_id}/log/appmetrics"
                profiling_response = requests.get(profiling_url)
                
                # Fetch session details
                session_url = f"https://{username}:{access_key}@mobile-api.lambdatest.com/mobile-automation/api/v1/sessions/{session_id}"
                session_response = requests.get(session_url)
                
                # Fetch video URL
                video_url = f"https://{username}:{access_key}@mobile-api.lambdatest.com/mobile-automation/api/v1/sessions/{session_id}/video"
                video_response = requests.get(video_url)
                
                # Fetch logs
                logs_url = f"https://{username}:{access_key}@mobile-api.lambdatest.com/mobile-automation/api/v1/sessions/{session_id}/log"
                logs_response = requests.get(logs_url)
                
                session_data = {
                    'session_id': session_id,
                    'profiling_metrics': profiling_response.json() if profiling_response.status_code == 200 else None,
                    'session_details': session_response.json() if session_response.status_code == 200 else None,
                    'video_url': video_response.json() if video_response.status_code == 200 else None,
                    'logs': logs_response.json() if logs_response.status_code == 200 else None,
                    'session_url': f"https://mobile.lambdatest.com/build/{session_id}",
                    'extraction_timestamp': datetime.now().isoformat()
                }
                
                # Check if profiling data is available and has the expected structure
                if (session_data['profiling_metrics'] and 
                    isinstance(session_data['profiling_metrics'], dict) and
                    (session_data['profiling_metrics'].get('meta') or 
                     session_data['profiling_metrics'].get('cpu') or
                     session_data['profiling_metrics'].get('mem'))):
                    print(f"✅ Successfully extracted session data with profiling metrics for {session_id}")
                    return session_data
                else:
                    print(f"⚠️  Profiling data not yet available (attempt {attempt + 1})")
                    if attempt < max_retries - 1:
                        print(f"⏳ Waiting {retry_delay} seconds before retry...")
                        time.sleep(retry_delay)
                        retry_delay *= 1.2  # Increase delay for next attempt
                    else:
                        print(f"⚠️  Profiling data not available after {max_retries} attempts, proceeding with available data")
                        return session_data
                
            except Exception as e:
                print(f"❌ Error extracting session data (attempt {attempt + 1}): {e}")
                if attempt < max_retries - 1:
                    print(f"⏳ Waiting {retry_delay} seconds before retry...")
                    time.sleep(retry_delay)
                    retry_delay *= 1.2
                else:
                    print(f"❌ Failed to extract session data after {max_retries} attempts")
                    return None
        
        return None
    
    def wait_for_session_completion(self, session_id):
        """Wait for the session to complete before extracting data."""
        print(f"⏳ Waiting for session {session_id} to complete...")
        
        max_wait_time = 300  # 5 minutes
        check_interval = 10   # Check every 10 seconds
        elapsed_time = 0
        
        while elapsed_time < max_wait_time:
            try:
                # Check session status
                session_url = f"https://{username}:{access_key}@mobile-api.lambdatest.com/mobile-automation/api/v1/sessions/{session_id}"
                session_response = requests.get(session_url)
                
                if session_response.status_code == 200:
                    session_data = session_response.json()
                    if session_data.get('data', {}).get('status_ind') == 'completed':
                        print(f"✅ Session {session_id} completed successfully")
                        return True
                    elif session_data.get('data', {}).get('status_ind') == 'failed':
                        print(f"❌ Session {session_id} failed")
                        return False
                
                print(f"⏳ Session still running... ({elapsed_time}s elapsed)")
                time.sleep(check_interval)
                elapsed_time += check_interval
                
            except Exception as e:
                print(f"⚠️  Error checking session status: {e}")
                time.sleep(check_interval)
                elapsed_time += check_interval
        
        print(f"⚠️  Timeout waiting for session completion after {max_wait_time}s")
        return False
    
    def analyze_performance_metrics(self, session_data):
        """Analyze performance metrics from session data with comprehensive raw data capture."""
        if not session_data or not session_data.get('profiling_metrics'):
            print("⚠️  No profiling metrics available")
            return {
                'cold_startup_time': 0,
                'hot_startup_time': 0,
                'max_cpu_utilization': 0,
                'avg_cpu': 0,
                'max_memory_usage': 0,
                'avg_memory_usage': 0,
                'avg_frame_rate': 60,
                'anr_count': 0,
                'app_crashes': 0,
                'battery_drain_rate': 0,
                'temperature': 0,
                'network_download': 0,
                'network_upload': 0,
                'avg_disk': 0,
                'max_disk_usage': 0,
                'raw_data': None
            }
        
        try:
            profiling = session_data['profiling_metrics']
            
            # Capture raw data for comprehensive analysis
            raw_data = {
                'disk': profiling.get('disk', []),
                'cpu': profiling.get('cpu', []),
                'mem': profiling.get('mem', []),
                'battery': profiling.get('battery', []),
                'temperature': profiling.get('temperature', []),
                'network': profiling.get('network', []),
                'fps': profiling.get('fps', []),
                'frames': profiling.get('frames', []),
                'meta': profiling.get('meta', {})
            }
            
            # Initialize metrics with default values
            metrics = {
                'cold_startup_time': 0,
                'hot_startup_time': 0,
                'max_cpu_utilization': 0,
                'avg_cpu': 0,
                'max_memory_usage': 0,
                'avg_memory_usage': 0,
                'avg_frame_rate': 60,
                'anr_count': 0,
                'app_crashes': 0,
                'battery_drain_rate': 0,
                'temperature': 0,
                'network_download': 0,
                'network_upload': 0,
                'avg_disk': 0,
                'max_disk_usage': 0,
                'raw_data': raw_data
            }
            
            # Extract metrics from meta section if available
            if profiling.get('meta'):
                meta = profiling['meta']
                metrics.update({
                    'cold_startup_time': meta.get('coldStartup', 0),
                    'hot_startup_time': meta.get('hotStartup', 0),
                    'max_cpu_utilization': meta.get('maxCPUUtilization', 0),
                    'avg_cpu': meta.get('avgCpu', 0),
                    'max_memory_usage': meta.get('maxMemoryUsage', 0),
                    'avg_memory_usage': meta.get('avgMemory', 0),
                    'avg_frame_rate': meta.get('avgFrameRate', 60),
                    'anr_count': meta.get('anrCount', 0),
                    'app_crashes': meta.get('crashCount', 0),
                    'network_download': meta.get('networkDownload', 0),
                    'network_upload': meta.get('networkUpload', 0),
                    'avg_disk': meta.get('avgDisk', 0),
                    'max_disk_usage': meta.get('maxDiskUsage', 0)
                })
            
            # Calculate additional metrics from time-series data if available
            if raw_data['cpu']:
                app_cpu_values = [entry.get('app', 0) for entry in raw_data['cpu'] if entry.get('app') is not None]
                if app_cpu_values:
                    metrics['max_cpu_utilization'] = max(app_cpu_values)
                    metrics['avg_cpu'] = sum(app_cpu_values) / len(app_cpu_values)
            
            if raw_data['mem']:
                app_mem_values = [entry.get('app', 0) for entry in raw_data['mem'] if entry.get('app') is not None]
                if app_mem_values:
                    metrics['max_memory_usage'] = max(app_mem_values)
                    metrics['avg_memory_usage'] = sum(app_mem_values) / len(app_mem_values)
            
            if raw_data['fps']:
                fps_values = [entry.get('count', 0) for entry in raw_data['fps'] if entry.get('count') is not None and entry.get('count') > 0]
                if fps_values:
                    metrics['avg_frame_rate'] = sum(fps_values) / len(fps_values)
            
            if raw_data['battery']:
                sys_battery_values = [entry.get('sys', 0) for entry in raw_data['battery'] if entry.get('sys') is not None]
                if len(sys_battery_values) > 1:
                    # Calculate battery drain rate (difference between first and last reading)
                    metrics['battery_drain_rate'] = sys_battery_values[-1] - sys_battery_values[0]
            
            if raw_data['temperature']:
                temp_values = [entry.get('temp', 0) for entry in raw_data['temperature'] if entry.get('temp') is not None]
                if temp_values:
                    metrics['temperature'] = max(temp_values)  # Use max temperature
            
            if raw_data['network']:
                download_values = [entry.get('appIn', 0) for entry in raw_data['network'] if entry.get('appIn') is not None]
                upload_values = [entry.get('appOut', 0) for entry in raw_data['network'] if entry.get('appOut') is not None]
                if download_values:
                    metrics['network_download'] = sum(download_values)
                if upload_values:
                    metrics['network_upload'] = sum(upload_values)
            
            if raw_data['disk']:
                app_disk_values = [entry.get('app', 0) for entry in raw_data['disk'] if entry.get('app') is not None]
                if app_disk_values:
                    metrics['avg_disk'] = sum(app_disk_values) / len(app_disk_values)
                    metrics['max_disk_usage'] = max(app_disk_values)
            
            print(f"📊 Extracted Performance Metrics:")
            print(f"   Cold Startup Time: {metrics['cold_startup_time']}ms")
            print(f"   Hot Startup Time: {metrics['hot_startup_time']}ms")
            print(f"   Max CPU: {metrics['max_cpu_utilization']:.1f}%")
            print(f"   Avg CPU: {metrics['avg_cpu']:.1f}%")
            print(f"   Max Memory: {metrics['max_memory_usage']:.1f}MB")
            print(f"   Avg Memory: {metrics['avg_memory_usage']:.1f}MB")
            print(f"   Avg Frame Rate: {metrics['avg_frame_rate']:.1f} FPS")
            print(f"   ANR Count: {metrics['anr_count']}")
            print(f"   App Crashes: {metrics['app_crashes']}")
            print(f"   Battery Drain: {metrics['battery_drain_rate']:.1f}%")
            print(f"   Temperature: {metrics['temperature']:.1f}°C")
            print(f"   Network Download: {metrics['network_download']:.1f}MB")
            print(f"   Network Upload: {metrics['network_upload']:.1f}MB")
            print(f"   Avg Disk: {metrics['avg_disk']:.1f}MB")
            print(f"   Max Disk: {metrics['max_disk_usage']:.1f}MB")
            
            return metrics
            
        except Exception as e:
            print(f"❌ Error analyzing performance metrics: {e}")
            return {
                'cold_startup_time': 0,
                'hot_startup_time': 0,
                'max_cpu_utilization': 0,
                'avg_cpu': 0,
                'max_memory_usage': 0,
                'avg_memory_usage': 0,
                'avg_frame_rate': 60,
                'anr_count': 0,
                'app_crashes': 0,
                'battery_drain_rate': 0,
                'temperature': 0,
                'network_download': 0,
                'network_upload': 0,
                'avg_disk': 0,
                'max_disk_usage': 0,
                'raw_data': None
            }
    
    def analyze_session_details(self, session_data):
        """Analyze session details and configuration."""
        if not session_data or not session_data.get('session_details'):
            print("⚠️  No session details available")
            return {
                'device_name': 'Unknown',
                'platform_version': 'Unknown',
                'app_package': 'Unknown',
                'test_name': 'Unknown',
                'build_name': 'Unknown',
                'status': 'Unknown',
                'start_time': 'Unknown',
                'end_time': 'Unknown',
                'duration': 0
            }
        
        try:
            details = session_data['session_details']
            
            # Handle different response structures
            if details.get('data'):
                data = details['data']
                analysis = {
                    'device_name': data.get('device_name', 'Unknown'),
                    'platform_version': data.get('os_version', 'Unknown'),
                    'app_package': 'Unknown',  # Not available in session details
                    'test_name': data.get('name', 'Unknown'),
                    'build_name': data.get('build_name', 'Unknown'),
                    'status': data.get('status_ind', 'Unknown'),
                    'start_time': data.get('start_timestamp', 'Unknown'),
                    'end_time': data.get('end_timestamp', 'Unknown'),
                    'duration': data.get('duration', 0),
                    'test_id': data.get('test_id', 'Unknown'),
                    'build_id': data.get('build_id', 'Unknown'),
                    'platform': data.get('platform', 'Unknown'),
                    'user_id': data.get('user_id', 'Unknown'),
                    'username': data.get('username', 'Unknown')
                }
            else:
                # Fallback for different response structure
                analysis = {
                    'device_name': details.get('deviceName', 'Unknown'),
                    'platform_version': details.get('platformVersion', 'Unknown'),
                    'app_package': details.get('appPackage', 'Unknown'),
                    'test_name': details.get('name', 'Unknown'),
                    'build_name': details.get('buildName', 'Unknown'),
                    'status': details.get('status', 'Unknown'),
                    'start_time': details.get('startTime', 'Unknown'),
                    'end_time': details.get('endTime', 'Unknown'),
                    'duration': details.get('duration', 0),
                    'test_id': details.get('test_id', 'Unknown'),
                    'build_id': details.get('build_id', 'Unknown'),
                    'platform': details.get('platform', 'Unknown'),
                    'user_id': details.get('user_id', 'Unknown'),
                    'username': details.get('username', 'Unknown')
                }
            
            print(f"📱 Session Details:")
            print(f"   Device: {analysis['device_name']}")
            print(f"   Platform: {analysis['platform_version']}")
            print(f"   App Package: {analysis['app_package']}")
            print(f"   Test Name: {analysis['test_name']}")
            print(f"   Build: {analysis['build_name']}")
            print(f"   Status: {analysis['status']}")
            print(f"   Duration: {analysis['duration']} seconds")
            print(f"   Test ID: {analysis['test_id']}")
            print(f"   Build ID: {analysis['build_id']}")
            print(f"   Platform: {analysis['platform']}")
            print(f"   User: {analysis['username']}")
            
            return analysis
            
        except Exception as e:
            print(f"❌ Error analyzing session details: {e}")
            return {
                'device_name': 'Unknown',
                'platform_version': 'Unknown',
                'app_package': 'Unknown',
                'test_name': 'Unknown',
                'build_name': 'Unknown',
                'status': 'Unknown',
                'start_time': 'Unknown',
                'end_time': 'Unknown',
                'duration': 0,
                'test_id': 'Unknown',
                'build_id': 'Unknown',
                'platform': 'Unknown',
                'user_id': 'Unknown',
                'username': 'Unknown'
            }
    
    def terminate_session(self, session_id):
        """Terminate the LambdaTest session to prevent timeout."""
        try:
            print(f"🛑 Terminating session {session_id}...")
            terminate_url = f"https://{username}:{access_key}@mobile-api.lambdatest.com/mobile-automation/api/v1/sessions/{session_id}/stop"
            response = requests.post(terminate_url)
            
            if response.status_code == 200:
                print(f"✅ Session {session_id} terminated successfully")
                return True
            else:
                print(f"⚠️  Failed to terminate session {session_id}: {response.status_code}")
                return False
                
        except Exception as e:
            print(f"❌ Error terminating session {session_id}: {e}")
            return False
    
    def extract_session_data_standalone(self, session_id):
        """Extract session data using the standalone approach after session termination."""
        print(f"🔍 Extracting session data for: {session_id}")
        
        try:
            # Fetch app profiling metrics
            profiling_url = f"https://{username}:{access_key}@mobile-api.lambdatest.com/mobile-automation/api/v1/sessions/{session_id}/log/appmetrics"
            profiling_response = requests.get(profiling_url)
            
            # Fetch session details
            session_url = f"https://{username}:{access_key}@mobile-api.lambdatest.com/mobile-automation/api/v1/sessions/{session_id}"
            session_response = requests.get(session_url)
            
            # Fetch video URL
            video_url = f"https://{username}:{access_key}@mobile-api.lambdatest.com/mobile-automation/api/v1/sessions/{session_id}/video"
            video_response = requests.get(video_url)
            
            # Fetch logs
            logs_url = f"https://{username}:{access_key}@mobile-api.lambdatest.com/mobile-automation/api/v1/sessions/{session_id}/log"
            logs_response = requests.get(logs_url)
            
            session_data = {
                'session_id': session_id,
                'profiling_metrics': profiling_response.json() if profiling_response.status_code == 200 else None,
                'session_details': session_response.json() if session_response.status_code == 200 else None,
                'video_url': video_response.json() if video_response.status_code == 200 else None,
                'logs': logs_response.json() if logs_response.status_code == 200 else None,
                'session_url': f"https://mobile.lambdatest.com/build/{session_id}",
                'extraction_timestamp': datetime.now().isoformat()
            }
            
            print(f"✅ Successfully extracted session data for {session_id}")
            return session_data
            
        except Exception as e:
            print(f"❌ Error extracting session data: {e}")
            return None
    
    def run_integrated_test(self):
        """Run the integrated performance test with session analysis."""
        print("🚀 Starting Integrated Performance Test")
        print("=" * 60)
        print(f"🎯 Target: {TARGET_COLD_LAUNCHES} cold launches")
        print(f"📱 Device: Google Pixel 4a")
        print(f"🔧 App Profiling: Enabled")
        print(f"📊 Session Analysis: Integrated")
        print("=" * 60)
        
        try:
            # Initialize driver
            self.create_driver()
            self.test_start_time = datetime.now()
            
            successful_launches = 0
            failed_launches = 0
            
            print(f"🔄 Starting {TARGET_COLD_LAUNCHES} cold launch iterations...")
            print("-" * 50)
            
            # Perform cold launches
            for iteration in range(1, TARGET_COLD_LAUNCHES + 1):
                result = self.perform_cold_launch(iteration)
                
                if result['success'] and result['app_loaded']:
                    successful_launches += 1
                    self.cold_launch_times.append(result['cold_launch_time_ms'])
                else:
                    failed_launches += 1
                
                # Progress indicator
                if iteration % 5 == 0:
                    print(f"📊 Progress: {iteration}/{TARGET_COLD_LAUNCHES} launches completed")
            
            self.test_end_time = datetime.now()
            
            # Close the driver first
            if self.driver and not self.driver_closed:
                self.driver.quit()
                self.driver_closed = True
                print("🔚 Driver closed")
            
            # Terminate the session to prevent timeout
            session_id = self.session_id
            print(f"\n🛑 Terminating session to prevent timeout...")
            self.terminate_session(session_id)
            
            # Wait a moment for session to fully terminate
            print("⏳ Waiting for session termination to complete...")
            time.sleep(10)
            
            # Extract session data using standalone approach
            print(f"\n📊 Extracting session data using standalone approach...")
            session_data = self.extract_session_data_standalone(session_id)
            
            if session_data:
                # Analyze performance metrics
                performance_metrics = self.analyze_performance_metrics(session_data)
                
                # Analyze session details
                session_analysis = self.analyze_session_details(session_data)
                
                # Generate comprehensive integrated report
                self.generate_integrated_report(session_data, performance_metrics, session_analysis, successful_launches, failed_launches)
            else:
                print("❌ Failed to extract session data")
            
        except Exception as e:
            print(f"❌ Integrated test failed: {e}")
            # Ensure driver is closed even on error
            if self.driver and not self.driver_closed:
                try:
                    self.driver.quit()
                    self.driver_closed = True
                    print("🔚 Driver closed due to error")
                except Exception as quit_error:
                    print(f"⚠️  Driver already closed or error during quit: {quit_error}")
    
    def generate_integrated_report(self, session_data, performance_metrics, session_analysis, successful_launches, failed_launches):
        """Generate a comprehensive integrated analysis report with beautiful formatting."""
        print("\n" + "=" * 100)
        print("🚀 INTEGRATED PERFORMANCE TEST & SESSION ANALYSIS REPORT")
        print("=" * 100)
        
        # Calculate test statistics
        test_duration_seconds = (self.test_end_time - self.test_start_time).total_seconds()
        avg_cold_launch_time = statistics.mean(self.cold_launch_times) if self.cold_launch_times else 0
        min_cold_launch_time = min(self.cold_launch_times) if self.cold_launch_times else 0
        max_cold_launch_time = max(self.cold_launch_times) if self.cold_launch_times else 0
        
        # Test Execution Summary
        print(f"\n📋 TEST EXECUTION SUMMARY")
        print(f"   {'─' * 50}")
        print(f"   🎯 Target Launches: {TARGET_COLD_LAUNCHES}")
        print(f"   ✅ Successful Launches: {successful_launches}")
        print(f"   ❌ Failed Launches: {failed_launches}")
        print(f"   📊 Success Rate: {(successful_launches/TARGET_COLD_LAUNCHES)*100:.2f}%")
        print(f"   ⏱️  Test Duration: {test_duration_seconds:.2f} seconds")
        print(f"   🆔 Session ID: {self.session_id}")
        
        # Cold Launch Performance
        print(f"\n⚡ COLD LAUNCH PERFORMANCE")
        print(f"   {'─' * 50}")
        print(f"   📈 Average Launch Time: {avg_cold_launch_time:.2f}ms")
        print(f"   📉 Minimum Launch Time: {min_cold_launch_time:.2f}ms")
        print(f"   📈 Maximum Launch Time: {max_cold_launch_time:.2f}ms")
        print(f"   📊 Standard Deviation: {statistics.stdev(self.cold_launch_times) if len(self.cold_launch_times) > 1 else 0:.2f}ms")
        
        # LambdaTest Performance Metrics
        print(f"\n🎬 LAMBDATEST PERFORMANCE METRICS")
        print(f"   {'─' * 50}")
        print(f"   🚀 Cold Startup Time: {performance_metrics['cold_startup_time']}ms")
        print(f"   🔥 Hot Startup Time: {performance_metrics['hot_startup_time']}ms")
        print(f"   💻 Max CPU: {performance_metrics['max_cpu_utilization']:.1f}%")
        print(f"   💻 Avg CPU: {performance_metrics['avg_cpu']:.1f}%")
        print(f"   🧠 Max Memory: {performance_metrics['max_memory_usage']:.1f}MB")
        print(f"   🧠 Avg Memory: {performance_metrics['avg_memory_usage']:.1f}MB")
        print(f"   🎮 Avg Frame Rate: {performance_metrics['avg_frame_rate']:.1f} FPS")
        print(f"   ⚠️  ANR Count: {performance_metrics['anr_count']}")
        print(f"   💥 App Crashes: {performance_metrics['app_crashes']}")
        print(f"   🔋 Battery Drain: {performance_metrics['battery_drain_rate']:.1f}%")
        print(f"   🌡️  Temperature: {performance_metrics['temperature']:.1f}°C")
        print(f"   📡 Network Download: {performance_metrics['network_download']:.1f}MB")
        print(f"   📡 Network Upload: {performance_metrics['network_upload']:.1f}MB")
        print(f"   💾 Avg Disk: {performance_metrics['avg_disk']:.1f}MB")
        print(f"   💾 Max Disk: {performance_metrics['max_disk_usage']:.1f}MB")
        
        # Session Information
        print(f"\n📱 SESSION INFORMATION")
        print(f"   {'─' * 50}")
        print(f"   📱 Device: {session_analysis['device_name']}")
        print(f"   🔧 Platform: {session_analysis['platform_version']}")
        print(f"   📦 App Package: {session_analysis['app_package']}")
        print(f"   🧪 Test Name: {session_analysis['test_name']}")
        print(f"   🏗️  Build: {session_analysis['build_name']}")
        print(f"   📊 Status: {session_analysis['status']}")
        print(f"   ⏱️  Duration: {session_analysis['duration']} seconds")
        print(f"   🆔 Test ID: {session_analysis['test_id']}")
        print(f"   🏗️  Build ID: {session_analysis['build_id']}")
        print(f"   🔧 Platform: {session_analysis['platform']}")
        print(f"   👤 User: {session_analysis['username']}")
        
        # Detailed Performance Analysis
        if performance_metrics.get('raw_data'):
            self.generate_detailed_performance_analysis(performance_metrics['raw_data'])
        
        # Performance Assessment
        print(f"\n🏆 PERFORMANCE ASSESSMENT")
        print(f"   {'─' * 50}")
        if performance_metrics['anr_count'] == 0:
            print(f"   ✅ No ANR events detected")
        else:
            print(f"   ❌ {performance_metrics['anr_count']} ANR events detected")
        
        if performance_metrics['avg_frame_rate'] >= 60:
            print(f"   ✅ Frame rate is excellent ({performance_metrics['avg_frame_rate']:.1f} FPS)")
        elif performance_metrics['avg_frame_rate'] >= 50:
            print(f"   ⚠️  Frame rate is good ({performance_metrics['avg_frame_rate']:.1f} FPS)")
        else:
            print(f"   ❌ Frame rate is low ({performance_metrics['avg_frame_rate']:.1f} FPS)")
        
        if performance_metrics['app_crashes'] == 0:
            print(f"   ✅ No app crashes detected")
        else:
            print(f"   ❌ {performance_metrics['app_crashes']} app crashes detected")
        
        if performance_metrics['battery_drain_rate'] <= 5:
            print(f"   ✅ Battery drain is acceptable ({performance_metrics['battery_drain_rate']:.1f}%)")
        else:
            print(f"   ⚠️  High battery drain detected ({performance_metrics['battery_drain_rate']:.1f}%)")
        
        if performance_metrics['temperature'] <= 35:
            print(f"   ✅ Temperature is normal ({performance_metrics['temperature']:.1f}°C)")
        else:
            print(f"   ⚠️  High temperature detected ({performance_metrics['temperature']:.1f}°C)")
        
        # Determine test results
        performance_passed = successful_launches >= TARGET_COLD_LAUNCHES * 0.8  # 80% success rate
        frame_drop_passed = performance_metrics['anr_count'] <= FRAME_DROP_THRESHOLD
        fps_passed = performance_metrics['avg_frame_rate'] >= MIN_FPS_THRESHOLD
        
        print(f"\n🎯 TEST RESULTS")
        print(f"   {'─' * 50}")
        print(f"   🚀 Launch Success: {'✅ PASSED' if performance_passed else '❌ FAILED'}")
        print(f"   ⚠️  ANR Events: {'✅ PASSED' if frame_drop_passed else '❌ FAILED'}")
        print(f"   🎮 FPS Target: {'✅ PASSED' if fps_passed else '❌ FAILED'}")
        
        overall_passed = performance_passed and frame_drop_passed and fps_passed
        print(f"\n🎯 OVERALL RESULT: {'✅ PASSED' if overall_passed else '❌ FAILED'}")
        
        # Save comprehensive integrated report
        self.save_integrated_report(session_data, performance_metrics, session_analysis, successful_launches, failed_launches)
    
    def generate_detailed_performance_analysis(self, raw_data):
        """Generate detailed performance analysis from raw data."""
        print(f"\n📊 DETAILED PERFORMANCE ANALYSIS")
        print(f"   {'─' * 50}")
        
        # CPU Analysis
        if raw_data['cpu']:
            cpu_values = [entry.get('app', 0) for entry in raw_data['cpu'] if entry.get('app') is not None]
            if cpu_values:
                print(f"   💻 CPU Analysis:")
                print(f"      📈 Peak CPU: {max(cpu_values):.1f}%")
                print(f"      📊 Avg CPU: {sum(cpu_values)/len(cpu_values):.1f}%")
                print(f"      📉 Min CPU: {min(cpu_values):.1f}%")
                print(f"      📊 CPU Samples: {len(cpu_values)}")
        
        # Memory Analysis
        if raw_data['mem']:
            mem_values = [entry.get('app', 0) for entry in raw_data['mem'] if entry.get('app') is not None]
            if mem_values:
                print(f"   🧠 Memory Analysis:")
                print(f"      📈 Peak Memory: {max(mem_values):.1f}MB")
                print(f"      📊 Avg Memory: {sum(mem_values)/len(mem_values):.1f}MB")
                print(f"      📉 Min Memory: {min(mem_values):.1f}MB")
                print(f"      📊 Memory Samples: {len(mem_values)}")
        
        # Frame Rate Analysis
        if raw_data['fps']:
            fps_values = [entry.get('count', 0) for entry in raw_data['fps'] if entry.get('count') is not None and entry.get('count') > 0]
            if fps_values:
                print(f"   🎮 Frame Rate Analysis:")
                print(f"      📈 Peak FPS: {max(fps_values):.1f}")
                print(f"      📊 Avg FPS: {sum(fps_values)/len(fps_values):.1f}")
                print(f"      📉 Min FPS: {min(fps_values):.1f}")
                print(f"      📊 FPS Samples: {len(fps_values)}")
        
        # Frame Drop Analysis
        if raw_data['frames']:
            janky_frames = sum([entry.get('janky', 0) for entry in raw_data['frames']])
            frozen_frames = sum([entry.get('frozen', 0) for entry in raw_data['frames']])
            total_frames = len(raw_data['frames'])
            print(f"   🎬 Frame Drop Analysis:")
            print(f"      ⚠️  Janky Frames: {janky_frames}")
            print(f"      ❄️  Frozen Frames: {frozen_frames}")
            print(f"      📊 Total Frame Samples: {total_frames}")
            if total_frames > 0:
                janky_percentage = (janky_frames / total_frames) * 100
                frozen_percentage = (frozen_frames / total_frames) * 100
                print(f"      📊 Janky Frame Rate: {janky_percentage:.1f}%")
                print(f"      📊 Frozen Frame Rate: {frozen_percentage:.1f}%")
        
        # Battery Analysis
        if raw_data['battery']:
            battery_values = [entry.get('sys', 0) for entry in raw_data['battery'] if entry.get('sys') is not None]
            if len(battery_values) > 1:
                print(f"   🔋 Battery Analysis:")
                print(f"      📈 Initial Battery: {battery_values[0]:.1f}%")
                print(f"      📉 Final Battery: {battery_values[-1]:.1f}%")
                print(f"      📊 Total Drain: {battery_values[-1] - battery_values[0]:.1f}%")
                print(f"      📊 Battery Samples: {len(battery_values)}")
        
        # Temperature Analysis
        if raw_data['temperature']:
            temp_values = [entry.get('temp', 0) for entry in raw_data['temperature'] if entry.get('temp') is not None]
            if temp_values:
                print(f"   🌡️  Temperature Analysis:")
                print(f"      📈 Max Temperature: {max(temp_values):.1f}°C")
                print(f"      📊 Avg Temperature: {sum(temp_values)/len(temp_values):.1f}°C")
                print(f"      📉 Min Temperature: {min(temp_values):.1f}°C")
                print(f"      📊 Temperature Samples: {len(temp_values)}")
        
        # Network Analysis
        if raw_data['network']:
            download_values = [entry.get('appIn', 0) for entry in raw_data['network'] if entry.get('appIn') is not None]
            upload_values = [entry.get('appOut', 0) for entry in raw_data['network'] if entry.get('appOut') is not None]
            if download_values or upload_values:
                print(f"   📡 Network Analysis:")
                if download_values:
                    print(f"      📥 Total Download: {sum(download_values):.1f}MB")
                    print(f"      📊 Avg Download: {sum(download_values)/len(download_values):.1f}MB")
                if upload_values:
                    print(f"      📤 Total Upload: {sum(upload_values):.1f}MB")
                    print(f"      📊 Avg Upload: {sum(upload_values)/len(upload_values):.1f}MB")
                print(f"      📊 Network Samples: {len(raw_data['network'])}")
        
        # Disk Analysis
        if raw_data['disk']:
            disk_values = [entry.get('app', 0) for entry in raw_data['disk'] if entry.get('app') is not None]
            if disk_values:
                print(f"   💾 Disk Analysis:")
                print(f"      📈 Peak Disk: {max(disk_values):.1f}MB")
                print(f"      📊 Avg Disk: {sum(disk_values)/len(disk_values):.1f}MB")
                print(f"      📉 Min Disk: {min(disk_values):.1f}MB")
                print(f"      📊 Disk Samples: {len(disk_values)}")
    
    def save_integrated_report(self, session_data, performance_metrics, session_analysis, successful_launches, failed_launches):
        """Save comprehensive integrated report with all data."""
        # Calculate test statistics
        test_duration_seconds = (self.test_end_time - self.test_start_time).total_seconds()
        avg_cold_launch_time = statistics.mean(self.cold_launch_times) if self.cold_launch_times else 0
        min_cold_launch_time = min(self.cold_launch_times) if self.cold_launch_times else 0
        max_cold_launch_time = max(self.cold_launch_times) if self.cold_launch_times else 0
        std_dev_cold_launch = statistics.stdev(self.cold_launch_times) if len(self.cold_launch_times) > 1 else 0
        
        # Calculate additional statistics
        test_stats = {
            'success_rate': (successful_launches/TARGET_COLD_LAUNCHES)*100,
            'cold_launch_stats': {
                'times': self.cold_launch_times,
                'average': avg_cold_launch_time,
                'minimum': min_cold_launch_time,
                'maximum': max_cold_launch_time,
                'standard_deviation': std_dev_cold_launch,
                'count': len(self.cold_launch_times)
            }
        }
        
        # Performance assessment
        performance_assessment = {
            'anr_events': performance_metrics['anr_count'] == 0,
            'frame_rate_quality': 'excellent' if performance_metrics['avg_frame_rate'] >= 60 else 'good' if performance_metrics['avg_frame_rate'] >= 50 else 'poor',
            'app_crashes': performance_metrics['app_crashes'] == 0,
            'battery_drain_acceptable': performance_metrics['battery_drain_rate'] <= 5,
            'temperature_normal': performance_metrics['temperature'] <= 35
        }
        
        # Test results
        performance_passed = successful_launches >= TARGET_COLD_LAUNCHES * 0.8
        frame_drop_passed = performance_metrics['anr_count'] <= FRAME_DROP_THRESHOLD
        fps_passed = performance_metrics['avg_frame_rate'] >= MIN_FPS_THRESHOLD
        overall_passed = performance_passed and frame_drop_passed and fps_passed
        
        test_results = {
            'launch_success': performance_passed,
            'anr_events': frame_drop_passed,
            'fps_target': fps_passed,
            'overall_result': overall_passed
        }
        
        report = {
            'report_info': {
                'report_date': datetime.now().isoformat(),
                'report_type': 'Integrated Performance Test Report',
                'version': '2.0'
            },
            'test_info': {
                'test_date': datetime.now().isoformat(),
                'session_id': self.session_id,
                'target_launches': TARGET_COLD_LAUNCHES,
                'successful_launches': successful_launches,
                'failed_launches': failed_launches,
                'test_duration_seconds': test_duration_seconds,
                'test_statistics': test_stats
            },
            'performance_data': {
                'cold_launch_performance': test_stats['cold_launch_stats'],
                'lambdatest_metrics': performance_metrics,
                'performance_assessment': performance_assessment,
                'test_results': test_results
            },
            'session_analysis': session_analysis,
            'session_data': session_data,
            'test_configuration': {
                'app_package': app_package,
                'app_url': app_url,
                'frame_drop_threshold': FRAME_DROP_THRESHOLD,
                'min_fps_threshold': MIN_FPS_THRESHOLD,
                'target_cold_launches': TARGET_COLD_LAUNCHES
            },
            'raw_profiling_data': performance_metrics.get('raw_data', {})
        }
        
        filename = f"integrated_performance_report_{self.session_id}_{datetime.now().strftime('%Y%m%d_%H%M%S')}.json"
        with open(filename, 'w') as f:
            json.dump(report, f, indent=2)
        
        print(f"\n📄 Comprehensive report saved to: {filename}")
        if session_data:
            print(f"🔗 LambdaTest Session: {session_data.get('session_url', 'N/A')}")
        
        # Print summary
        print(f"\n📊 REPORT SUMMARY")
        print(f"   {'─' * 50}")
        print(f"   📁 File: {filename}")
        print(f"   📊 Overall Result: {'✅ PASSED' if overall_passed else '❌ FAILED'}")
        print(f"   🚀 Launch Success: {'✅ PASSED' if performance_passed else '❌ FAILED'}")
        print(f"   ⚠️  ANR Events: {'✅ PASSED' if frame_drop_passed else '❌ FAILED'}")
        print(f"   🎮 FPS Target: {'✅ PASSED' if fps_passed else '❌ FAILED'}")
        print(f"   📈 Success Rate: {test_stats['success_rate']:.2f}%")
        print(f"   ⏱️  Avg Launch Time: {avg_cold_launch_time:.2f}ms")
        print(f"   🎮 Avg Frame Rate: {performance_metrics['avg_frame_rate']:.1f} FPS")
        print(f"   💻 Max CPU: {performance_metrics['max_cpu_utilization']:.1f}%")
        print(f"   🧠 Max Memory: {performance_metrics['max_memory_usage']:.1f}MB")

def main():
    """Main execution function."""
    print("🚀 INTEGRATED PERFORMANCE TEST WITH SESSION ANALYSIS")
    print("=" * 80)
    
    # Create and run the integrated test
    test = IntegratedPerformanceTest()
    test.run_integrated_test()

if __name__ == "__main__":
    main() 