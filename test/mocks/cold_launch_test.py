import os
import time
import csv
from datetime import datetime

PACKAGE_NAME = "com.example.sliq_pay"
MAIN_ACTIVITY = "MainActivity"
TOTAL_LAUNCHES = 20
SLEEP_BETWEEN_LAUNCHES = 10
OUTPUT_CSV = "cold_launch_results.csv"

def clear_app_data():
    os.system(f"adb shell pm clear {PACKAGE_NAME}")

def launch_app():
    start_time = time.time()
    os.system(f"adb shell am start -n {PACKAGE_NAME}/.{MAIN_ACTIVITY}")
    time.sleep(SLEEP_BETWEEN_LAUNCHES)
    end_time = time.time()
    return end_time - start_time

def get_frame_stats():
    raw_output = os.popen(f"adb shell dumpsys gfxinfo {PACKAGE_NAME} framestats").read()
    frame_lines = [line for line in raw_output.splitlines() if line.startswith("Flags")]
    janky_frames = len([line for line in frame_lines if "Janky" in line])
    total_frames = len(frame_lines)
    return total_frames, janky_frames

def perform_load_test():
    results = [("Iteration", "StartupTime(s)", "TotalFrames", "JankyFrames", "Timestamp")]
    for i in range(TOTAL_LAUNCHES):
        print(f"🔁 Launch {i + 1}/{TOTAL_LAUNCHES}")
        clear_app_data()
        startup_time = launch_app()
        total_frames, janky_frames = get_frame_stats()
        timestamp = datetime.now().isoformat()
        results.append((i + 1, round(startup_time, 3), total_frames, janky_frames, timestamp))
    return results

data = perform_load_test()
with open(OUTPUT_CSV, "w", newline="") as f:
    writer = csv.writer(f)
    writer.writerows(data)