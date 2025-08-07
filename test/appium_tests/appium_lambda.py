from appium import webdriver
from appium.options.android import UiAutomator2Options
from selenium.webdriver.common.by import By
from appium.webdriver.common.appiumby import AppiumBy
import time
import warnings

warnings.filterwarnings("ignore", message="Embedding username and password in URL could be insecure")

username = "lakshmivankayalapati"
access_key = "LT_D4KfZYw80A6JvF1Wnlrnu0db9JuT7knmEode8ZR6I1oZncw"

# Create options object instead of using desired_capabilities
options = UiAutomator2Options()
options.platform_name = "Android"
options.device_name = "Google Pixel 4a"
options.platform_version = "12"  # Adjust if you're using a different Android version
options.set_capability("isRealMobile", True)
options.set_capability("app", "lt://APP1016057671753726420977541")  # Replace with your app identifier from LambdaTest
options.set_capability("build", "Pixel 4a UI Test Swipe revised")
options.set_capability("name", "Carousel + Button Flow")
options.set_capability("deviceOrientation", "PORTRAIT")

driver = webdriver.Remote(
    command_executor = f"https://{username}:{access_key}@mobile-hub.lambdatest.com/wd/hub",
    options = options
)

try:
    # Wait for app to load
    time.sleep(5)
    
    # Carousel XPaths - simplified selectors
    slideXPaths = [
        '//*[contains(@content-desc, "Pay Anywhere")]',
        '//*[contains(@content-desc, "Your Money")]',
        '//*[contains(@content-desc, "What You See")]'
    ]

    print("\n🔁 Checking Carousel Rotation...")
    
    # Function to detect current slide
    def detect_current_slide():
        for i, xpath in enumerate(slideXPaths):
            try:
                driver.find_element(By.XPATH, xpath)
                return i + 1  # Return slide number (1, 2, or 3)
            except:
                continue
        return None
    
    # Detect which slide is currently visible
    initial_slide = detect_current_slide()
    if initial_slide:
        print(f"📍 Starting on Slide {initial_slide}")
        
        # Wait and track all slides that appear
        print("⏱️  Waiting for carousel cycle to complete...")
        slides_seen = set()
        slides_seen.add(initial_slide)
        
        # Wait for up to 20 seconds to see all slides
        start_time = time.time()
        timeout = 20  # 20 seconds timeout
        
        while len(slides_seen) < 3 and (time.time() - start_time) < timeout:
            time.sleep(2)  # Check every 2 seconds
            current_slide = detect_current_slide()
            if current_slide:
                if current_slide not in slides_seen:
                    print(f"✅ Slide {current_slide} appeared")
                    slides_seen.add(current_slide)
                else:
                    print(f"🔄 Slide {current_slide} (already seen)")
            else:
                print("❓ No slide detected")
        
        # Report results
        if len(slides_seen) == 3:
            print("✅ All 3 slides appeared in carousel cycle")
            print(f"📊 Slides seen: {sorted(slides_seen)}")
        else:
            print(f"⚠️  Only {len(slides_seen)} slides appeared: {sorted(slides_seen)}")
            print("⏰ Timeout reached or cycle incomplete")
    else:
        print("❌ Could not detect any slides initially")

    # --- Intelligent Swipe Gesture Testing ---
    print("\n👆 Testing intelligent swipe gestures...")
    
    # Get window size for swipe calculations
    window_size = driver.get_window_size()
    print(f"📱 Window size: {window_size['width']}x{window_size['height']}")
    
    # Function to perform swipe and check result
    def perform_swipe_test(direction, test_name):
        try:
            driver.execute_script("mobile: swipeGesture", {
                "left": 0,
                "top": 0,
                "width": window_size['width'],
                "height": window_size['height'],
                "direction": direction,
                "percent": 0.75
            })
            print(f"✅ {test_name} swipe executed successfully")
            time.sleep(1.5)  # Wait for animation
            return True
        except Exception as e:
            print(f"❌ {test_name} swipe failed: {e}")
            return False
    
    # Detect current slide
    current_slide = detect_current_slide()
    if current_slide:
        print(f"📍 Currently on Slide {current_slide}")
        
        if current_slide == 1:
            print("\n🔄 Testing Slide 1 navigation...")
            # Slide 1: Right to left (should go to slide 2), then left to right (should return to slide 1)
            
            # First swipe: right to left
            if perform_swipe_test("left", "Slide 1 → Slide 2"):
                time.sleep(1)
                new_slide = detect_current_slide()
                if new_slide == 2:
                    print("✅ Successfully navigated from Slide 1 to Slide 2")
                    
                    # Second swipe: left to right (should return to slide 1)
                    if perform_swipe_test("right", "Slide 2 → Slide 1"):
                        time.sleep(1)
                        final_slide = detect_current_slide()
                        if final_slide == 1:
                            print("✅ Successfully returned to Slide 1")
                        else:
                            print(f"❌ Failed to return to Slide 1, currently on Slide {final_slide}")
                    else:
                        print("❌ Failed to swipe back to Slide 1")
                else:
                    print(f"❌ Failed to navigate to Slide 2, currently on Slide {new_slide}")
            else:
                print("❌ Failed to swipe from Slide 1 to Slide 2")
                
        elif current_slide == 2:
            print("\n🔄 Testing Slide 2 navigation...")
            # Slide 2: Can go either direction, let's try right to left first
            
            # First swipe: right to left (should go to slide 3)
            if perform_swipe_test("left", "Slide 2 → Slide 3"):
                time.sleep(1)
                new_slide = detect_current_slide()
                if new_slide == 3:
                    print("✅ Successfully navigated from Slide 2 to Slide 3")
                    
                    # Second swipe: left to right (should return to slide 2)
                    if perform_swipe_test("right", "Slide 3 → Slide 2"):
                        time.sleep(1)
                        final_slide = detect_current_slide()
                        if final_slide == 2:
                            print("✅ Successfully returned to Slide 2")
                        else:
                            print(f"❌ Failed to return to Slide 2, currently on Slide {final_slide}")
                    else:
                        print("❌ Failed to swipe back to Slide 2")
                else:
                    print(f"❌ Failed to navigate to Slide 3, currently on Slide {new_slide}")
            else:
                print("❌ Failed to swipe from Slide 2 to Slide 3")
                
        elif current_slide == 3:
            print("\n🔄 Testing Slide 3 navigation...")
            # Slide 3: Left to right (should go to slide 2), then right to left (should return to slide 3)
            
            # First swipe: left to right
            if perform_swipe_test("right", "Slide 3 → Slide 2"):
                time.sleep(1)
                new_slide = detect_current_slide()
                if new_slide == 2:
                    print("✅ Successfully navigated from Slide 3 to Slide 2")
                    
                    # Second swipe: right to left (should return to slide 3)
                    if perform_swipe_test("left", "Slide 2 → Slide 3"):
                        time.sleep(1)
                        final_slide = detect_current_slide()
                        if final_slide == 3:
                            print("✅ Successfully returned to Slide 3")
                        else:
                            print(f"❌ Failed to return to Slide 3, currently on Slide {final_slide}")
                    else:
                        print("❌ Failed to swipe back to Slide 3")
                else:
                    print(f"❌ Failed to navigate to Slide 2, currently on Slide {new_slide}")
            else:
                print("❌ Failed to swipe from Slide 3 to Slide 2")
    else:
        print("❌ Could not detect current slide")

    # Test 1: Get Started button flow
    print("\n🚀 Test 1: Clicking 'Get Started' button...")
    get_started_btn = driver.find_element(By.XPATH, "//android.view.View[@content-desc='Get Started']")
    print("✅ Found 'Get Started' button")
    
    get_started_btn.click()
    time.sleep(3)  # Increased wait time
    
    # Check for signup screen
    signup_text = driver.find_element(By.XPATH, "//*[@content-desc='Signup Screen']")
    print("✅ Found signup screen")
    print("✅ 'Signup Screen' opened successfully.")

    # Restart the app for the login test
    print("\n🔄 Restarting app for login test...")
    driver.quit()
    
    # Recreate the driver
    driver = webdriver.Remote(
        command_executor = f"https://{username}:{access_key}@mobile-hub.lambdatest.com/wd/hub",
        options = options
    )
    
    # Wait for app to load again
    time.sleep(5)

    # Test 2: Log In button flow
    print("\n🔐 Test 2: Clicking 'Log In' button...")
    login_btn = driver.find_element(By.XPATH, "//*[@content-desc='Log In']")
    print("✅ Found 'Log In' button")
    
    login_btn.click()
    time.sleep(3)  # Increased wait time
    
    # Check for login screen
    login_text = driver.find_element(By.XPATH, "//*[@content-desc='Login Screen']")
    print("✅ Found login screen")
    print("✅ 'Login Screen' opened successfully.")

finally:
    driver.quit()
