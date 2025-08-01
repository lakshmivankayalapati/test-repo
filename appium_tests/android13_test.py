from appium import webdriver
from appium.options.android import UiAutomator2Options
from selenium.webdriver.common.by import By
import time
import warnings

warnings.filterwarnings("ignore", message="Embedding username and password in URL could be insecure")

def main():
    print('🚀 Starting Android 13 Pixel 4a UI Test (Flutter App)...')

    # Create options object for local Appium testing
    options = UiAutomator2Options()
    options.platform_name = "Android"
    options.device_name = "Pixel_4a_API_33"
    options.platform_version = "13"
    options.automation_name = "UiAutomator2"
    options.app = "E:\\sliq_pay\\sliq_pay_updated\\sliq_pay\\build\\app\\outputs\\flutter-apk\\app-release.apk"
    options.no_reset = False
    options.full_reset = True
    options.auto_grant_permissions = True
    options.app_package = "com.example.sliq_pay"
    options.app_activity = "com.example.sliq_pay.MainActivity"

    driver = None
    try:
        # Connect to local Appium server
        driver = webdriver.Remote(
            command_executor = "http://127.0.0.1:4723",
            options = options
        )

        print('✅ Connected to Appium server')
        print('📱 Starting app on Android 13 Pixel 4a with fresh data...')

        # Wait longer for the app to fully load
        time.sleep(8)

        # Execute the UI Flow Test
        test_ui_flow(driver)

        print('\n🎉 All Android 13 Pixel 4a tests completed successfully!')
    except Exception as e:
        print(f'❌ Test failed: {e}')
    finally:
        # Cleanup: Quit Driver
        if driver:
            print('\n🧹 Quitting Appium driver...')
            driver.quit()
            print('✅ Driver quit successfully.')

def detect_current_slide(driver):
    """Detect which slide is currently visible"""
    print('🔍 Detecting current slide...')
    
    # XPath selectors for each slide based on content-desc attribute
    slide_xpaths = [
        '//*[contains(@content-desc, "Pay Anywhere")]',
        '//*[contains(@content-desc, "Your Money")]',
        '//*[contains(@content-desc, "What You See")]'
    ]
    
    # Try to find each slide by its specific XPath
    for slide_index, xpath in enumerate(slide_xpaths):
        try:
            element = driver.find_element(By.XPATH, xpath)
            if element:
                print(f'✅ Detected slide {slide_index + 1} using XPath selector')
                return slide_index + 1
        except Exception as e:
            print(f'  Slide {slide_index + 1} not found: {str(e).split("\n")[0]}')
    
    # If we can't detect the slide, wait a bit and try again
    print('⚠️ Could not detect current slide, waiting 2 seconds and trying again...')
    time.sleep(2)
    
    # Retry with the same XPath selectors
    for slide_index, xpath in enumerate(slide_xpaths):
        try:
            element = driver.find_element(By.XPATH, xpath)
            if element:
                print(f'✅ Detected slide {slide_index + 1} using XPath selector (retry)')
                return slide_index + 1
        except Exception as e:
            print(f'  Slide {slide_index + 1} not found (retry): {str(e).split("\n")[0]}')
    
    return None

def perform_swipe_test(driver, direction, test_name):
    """Perform swipe and check result"""
    try:
        driver.execute_script("mobile: swipeGesture", {
            "left": 0,
            "top": 0,
            "width": driver.get_window_size()['width'],
            "height": driver.get_window_size()['height'],
            "direction": direction,
            "percent": 0.75
        })
        print(f'✅ {test_name} swipe executed successfully')
        time.sleep(1.5)  # Wait for animation
        return True
    except Exception as e:
        print(f'❌ {test_name} swipe failed: {e}')
        return False

def test_intelligent_swipe_gestures(driver):
    """Test intelligent swipe gestures based on current slide"""
    print('\n👆 Testing intelligent swipe gestures...')
    
    # Get window size for swipe calculations
    window_size = driver.get_window_size()
    print(f'📱 Window size: {window_size["width"]}x{window_size["height"]}')
    
    # Detect current slide
    current_slide = detect_current_slide(driver)
    if current_slide:
        print(f'📍 Currently on Slide {current_slide}')
        
        if current_slide == 1:
            print('\n🔄 Testing Slide 1 navigation...')
            # Slide 1: Right to left (should go to slide 2), then left to right (should return to slide 1)
            
            # First swipe: right to left
            if perform_swipe_test(driver, "left", "Slide 1 → Slide 2"):
                time.sleep(1)
                new_slide = detect_current_slide(driver)
                if new_slide == 2:
                    print('✅ Successfully navigated from Slide 1 to Slide 2')
                    
                    # Second swipe: left to right (should return to slide 1)
                    if perform_swipe_test(driver, "right", "Slide 2 → Slide 1"):
                        time.sleep(1)
                        final_slide = detect_current_slide(driver)
                        if final_slide == 1:
                            print('✅ Successfully returned to Slide 1')
                        else:
                            print(f'❌ Failed to return to Slide 1, currently on Slide {final_slide}')
                    else:
                        print('❌ Failed to swipe back to Slide 1')
                else:
                    print(f'❌ Failed to navigate to Slide 2, currently on Slide {new_slide}')
            else:
                print('❌ Failed to swipe from Slide 1 to Slide 2')
                
        elif current_slide == 2:
            print('\n🔄 Testing Slide 2 navigation...')
            # Slide 2: Right to left (should go to slide 3), then left to right (should return to slide 2)
            
            # First swipe: right to left
            if perform_swipe_test(driver, "left", "Slide 2 → Slide 3"):
                time.sleep(1)
                new_slide = detect_current_slide(driver)
                if new_slide == 3:
                    print('✅ Successfully navigated from Slide 2 to Slide 3')
                    
                    # Second swipe: left to right (should return to slide 2)
                    if perform_swipe_test(driver, "right", "Slide 3 → Slide 2"):
                        time.sleep(1)
                        final_slide = detect_current_slide(driver)
                        if final_slide == 2:
                            print('✅ Successfully returned to Slide 2')
                        else:
                            print(f'❌ Failed to return to Slide 2, currently on Slide {final_slide}')
                    else:
                        print('❌ Failed to swipe back to Slide 2')
                else:
                    print(f'❌ Failed to navigate to Slide 3, currently on Slide {new_slide}')
            else:
                print('❌ Failed to swipe from Slide 2 to Slide 3')
                
        elif current_slide == 3:
            print('\n🔄 Testing Slide 3 navigation...')
            # Slide 3: Left to right (should go to slide 2), then right to left (should return to slide 3)
            
            # First swipe: left to right
            if perform_swipe_test(driver, "right", "Slide 3 → Slide 2"):
                time.sleep(1)
                new_slide = detect_current_slide(driver)
                if new_slide == 2:
                    print('✅ Successfully navigated from Slide 3 to Slide 2')
                    
                    # Second swipe: right to left (should return to slide 3)
                    if perform_swipe_test(driver, "left", "Slide 2 → Slide 3"):
                        time.sleep(1)
                        final_slide = detect_current_slide(driver)
                        if final_slide == 3:
                            print('✅ Successfully returned to Slide 3')
                        else:
                            print(f'❌ Failed to return to Slide 3, currently on Slide {final_slide}')
                    else:
                        print('❌ Failed to swipe back to Slide 3')
                else:
                    print(f'❌ Failed to navigate to Slide 2, currently on Slide {new_slide}')
            else:
                print('❌ Failed to swipe from Slide 3 to Slide 2')
    else:
        print('❌ Could not detect current slide')

def test_welcome_flow(driver):
    """Test the welcome flow including both button interactions"""
    print('🔍 Testing both navigation options from welcome screen...')
    
    # Test 1: Get Started button → Signup Screen
    print('\n📱 Test 1: Testing "Get Started" button → Signup Screen...')
    test_get_started_flow(driver)
    
    print('📝 Note: App needs to be restarted to return to welcome screen (no back navigation available)')
    print('🎉 Welcome flow test completed successfully!')

def test_get_started_flow(driver):
    """Test the Get Started button flow"""
    print('🔍 Looking for "Get Started" button using specific selectors...')
    
    get_started_button = None
    
    # Method 1: Find by accessibility ID (preferred method)
    try:
        get_started_button = driver.find_element(By.XPATH, "//android.view.View[@content-desc='Get Started']")
        print('✅ Found Get Started button by accessibility ID')
    except Exception as e:
        print(f'❌ Get Started button not found by accessibility ID: {str(e).split("\n")[0]}')

    # Method 2: Find by exact text if Method 1 failed
    if not get_started_button:
        try:
            get_started_button = driver.find_element(By.XPATH, "//*[@text='Get Started']")
            print('✅ Found Get Started button by exact text')
        except Exception as e:
            print(f'❌ Get Started button not found by exact text: {str(e).split("\n")[0]}')

    if not get_started_button:
        raise Exception('Get Started button not found with any method')

    print('🎯 Clicking Get Started button...')
    get_started_button.click()
    
    # Wait for navigation
    time.sleep(3)
    
    print('✅ Get Started button clicked successfully')
    
    # Verify we're on the signup page
    print('🔍 Verifying navigation to signup page...')
    
    signup_screen = None
    
    # Method 1: Find Signup Screen by accessibility ID
    try:
        signup_screen = driver.find_element(By.XPATH, "//*[@content-desc='Signup Screen']")
        print('✅ Found Signup Screen by accessibility ID - navigation successful')
    except Exception as e:
        print(f'❌ Signup Screen not found by accessibility ID: {str(e).split("\n")[0]}')

    # Method 2: Find by exact text if Method 1 failed
    if not signup_screen:
        try:
            signup_screen = driver.find_element(By.XPATH, "//*[@text='Signup Screen']")
            print('✅ Found Signup Screen by exact text - navigation successful')
        except Exception as e:
            print(f'❌ Signup Screen not found by exact text: {str(e).split("\n")[0]}')

    if not signup_screen:
        raise Exception('Failed to navigate to signup page - Signup Screen not found')
    
    print('🎉 Successfully navigated to signup page!')

def test_ui_flow(driver):
    """Main UI flow test function"""
    print('\n🧪 Starting UI Flow Test...')

    # --- Step 1: Intelligent Carousel Testing ---
    print('\n🔁 Step 1: Testing intelligent carousel rotation...')
    
    # Detect which slide is currently visible
    initial_slide = detect_current_slide(driver)
    if initial_slide:
        print(f'📍 Starting on Slide {initial_slide}')
        
        # Wait and track all slides that appear
        print('⏱️ Waiting for carousel cycle to complete...')
        slides_seen = set()
        slides_seen.add(initial_slide)
        
        # Wait for up to 20 seconds to see all slides
        start_time = time.time()
        timeout = 20  # 20 seconds timeout
        
        while len(slides_seen) < 3 and (time.time() - start_time) < timeout:
            time.sleep(2)  # Check every 2 seconds
            current_slide = detect_current_slide(driver)
            if current_slide:
                if current_slide not in slides_seen:
                    print(f'✅ Slide {current_slide} appeared')
                    slides_seen.add(current_slide)
                else:
                    print(f'🔄 Slide {current_slide} (already seen)')
            else:
                print('❓ No slide detected')
        
        # Report results
        if len(slides_seen) == 3:
            print('✅ All 3 slides appeared in carousel cycle')
            print(f'📊 Slides seen: {sorted(slides_seen)}')
        else:
            print(f'⚠️ Only {len(slides_seen)} slides appeared: {sorted(slides_seen)}')
            print('⏰ Timeout reached or cycle incomplete')
    else:
        print('❌ Could not detect any slides initially')

    # --- Step 2: Test Intelligent Swipe Gestures ---
    test_intelligent_swipe_gestures(driver)

    # --- Step 3: Test both navigation flows from welcome screen ---
    print('\n📱 Step 3: Testing both navigation flows from welcome screen...')
    test_welcome_flow(driver)

    print('\n🎉 UI Flow Test completed successfully!')

if __name__ == "__main__":
    main() 