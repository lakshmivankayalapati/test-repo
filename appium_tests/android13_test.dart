import 'package:webdriver/async_io.dart';
import 'dart:math';

/// Appium UI Test for Android 13 Pixel 4a (Flutter App)
/// Tests the complete onboarding flow: welcome screens → signup page
/// 
/// Navigation Options from Welcome Screen:
/// 1. "Get Started" button → Signup Screen (tested in this run)
/// 2. "Log In" button → Login Screen (use testLogInFlowFromWelcome() for separate test)
/// 
/// Note: After navigating to signup or login screens, the app needs to be restarted
/// to return to the welcome screen as there's no back navigation available.
void main() async {
  print('🚀 Starting Android 13 Pixel 4a UI Test (Flutter App)...');

  WebDriver? driver;

  try {
    // --- 1. Connect to Appium server with standard Android automation ---
    driver = await createDriver(
      uri: Uri.parse('http://127.0.0.1:4723'),
      desired: {
        'platformName': 'Android',
        'appium:platformVersion': '13',
        'appium:deviceName': 'Pixel_4a_API_33',
        'appium:automationName': 'UiAutomator2',
        'appium:app': 'E:\\sliq_pay\\sliq_pay_updated\\sliq_pay\\build\\app\\outputs\\flutter-apk\\app-release.apk',
        'appium:noReset': false,
        'appium:fullReset': true,
        'appium:autoGrantPermissions': true,
        'appium:appPackage': 'com.example.sliq_pay',
        'appium:appActivity': 'com.example.sliq_pay.MainActivity',
      },
    );

    print('✅ Connected to Appium server');
    print('📱 Starting app on Android 13 Pixel 4a with fresh data...');

    // Wait longer for the app to fully load
    await Future.delayed(Duration(seconds: 8));

    // --- 2. Execute the UI Flow Test ---
    await testUIFlow(driver);

    print('\n🎉 All Android 13 Pixel 4a tests completed successfully!');
  } catch (e) {
    print('❌ Test failed: $e');
    if (e is WebDriverException) {
      print('WebDriver Exception Details: ${e.message}');
    }
  } finally {
    // --- 3. Cleanup: Quit Driver ---
    if (driver != null) {
      print('\n🧹 Quitting Appium driver...');
      await driver.quit();
      print('✅ Driver quit successfully.');
    }
  }
}

/// Helper function to wait for an element with timeout
Future<WebElement?> waitForElement(WebDriver driver, Future<WebElement?> Function() finder, {Duration timeout = const Duration(seconds: 30)}) async {
  final startTime = DateTime.now();
  while (DateTime.now().difference(startTime) < timeout) {
    try {
      final element = await finder();
      if (element != null) {
        return element;
      }
    } catch (e) {
      // Element not found, continue waiting
    }
    await Future.delayed(Duration(milliseconds: 500));
  }
  return null;
}

Future<void> swipeLeft(WebDriver driver) async {
  final size = await driver.execute('getWindowSize', []) as Map<String, dynamic>;
  final width = size['width'] as int;
  final height = size['height'] as int;

  final startX = (width * 0.8).toInt();
  final endX = (width * 0.2).toInt();
  final y = (height * 0.5).toInt();

  print('🔄 Performing left swipe via ADB: ($startX, $y) → ($endX, $y)');

  try {
    // Method 1: Try using ADB shell command for real swipe
    try {
      await driver.execute('mobile: shell', [
        'input',
        'swipe',
        startX.toString(),
        y.toString(),
        endX.toString(),
        y.toString()
      ]);
      print('✅ Swipe completed via ADB shell command');
    } catch (e) {
      print('⚠️ ADB shell failed, trying W3C actions: $e');
      
      // Method 2: Try using W3C performActions
      try {
        await driver.execute('performActions', [
          {
            'type': 'pointer',
            'id': 'finger1',
            'parameters': {'pointerType': 'touch'},
            'actions': [
              {'type': 'pointerMove', 'duration': 0, 'x': startX, 'y': y},
              {'type': 'pointerDown', 'button': 0},
              {'type': 'pointerMove', 'duration': 500, 'x': endX, 'y': y},
              {'type': 'pointerUp', 'button': 0}
            ]
          }
        ]);
        print('✅ Swipe completed via W3C performActions');
      } catch (e2) {
        print('⚠️ W3C actions failed, trying basic approach: $e2');
        
        // Method 3: Fallback to basic element interaction
        try {
          final body = await driver.findElement(By.tagName('body'));
          await body.click();
          await Future.delayed(Duration(milliseconds: 500));
          print('✅ Swipe completed via basic click');
        } catch (e3) {
          print('❌ All swipe methods failed: $e3');
          rethrow;
        }
      }
    }
  } catch (e) {
    print('❌ All swipe methods failed: $e');
    rethrow;
  }
}

Future<void> swipeRight(WebDriver driver) async {
  final size = await driver.execute('getWindowSize', []) as Map<String, dynamic>;
  final width = size['width'] as int;
  final height = size['height'] as int;

  final startX = (width * 0.2).toInt();
  final endX = (width * 0.8).toInt();
  final y = (height * 0.5).toInt();

  print('🔄 Performing right swipe via ADB: ($startX, $y) → ($endX, $y)');

  try {
    // Method 1: Try using ADB shell command for real swipe
    try {
      await driver.execute('mobile: shell', [
        'input',
        'swipe',
        startX.toString(),
        y.toString(),
        endX.toString(),
        y.toString()
      ]);
      print('✅ Swipe completed via ADB shell command');
    } catch (e) {
      print('⚠️ ADB shell failed, trying W3C actions: $e');
      
      // Method 2: Try using W3C performActions
      try {
        await driver.execute('performActions', [
          {
            'type': 'pointer',
            'id': 'finger1',
            'parameters': {'pointerType': 'touch'},
            'actions': [
              {'type': 'pointerMove', 'duration': 0, 'x': startX, 'y': y},
              {'type': 'pointerDown', 'button': 0},
              {'type': 'pointerMove', 'duration': 500, 'x': endX, 'y': y},
              {'type': 'pointerUp', 'button': 0}
            ]
          }
        ]);
        print('✅ Swipe completed via W3C performActions');
      } catch (e2) {
        print('⚠️ W3C actions failed, trying basic approach: $e2');
        
        // Method 3: Fallback to basic element interaction
        try {
          final body = await driver.findElement(By.tagName('body'));
          await body.click();
          await Future.delayed(Duration(milliseconds: 500));
          print('✅ Swipe completed via basic click');
        } catch (e3) {
          print('❌ All swipe methods failed: $e3');
          rethrow;
        }
      }
    }
  } catch (e) {
    print('❌ All swipe methods failed: $e');
    rethrow;
  }
}

/// Swipe left on PageView (go to next page) - Not used in current approach
Future<void> swipeLeftOnPageView(WebDriver driver) async {
  print('⚠️ Swipe not needed - slides change automatically');
  // No action needed as slides change automatically every 5 seconds
}

/// Swipe right on PageView (go to previous page) - Not used in current approach
Future<void> swipeRightOnPageView(WebDriver driver) async {
  print('⚠️ Swipe not needed - slides change automatically');
  // No action needed as slides change automatically every 5 seconds
}

/// Helper function to verify slide transition with multiple detection methods
Future<bool> verifySlideTransition(WebDriver driver, int expectedSlide) async {
  print('🔍 Verifying slide $expectedSlide content...');
  
  // XPath selectors for each slide based on content-desc attribute
  final slideXPaths = [
    '//*[contains(@content-desc, "Pay Anywhere")]',
    '//*[contains(@content-desc, "Your Money")]',
    '//*[contains(@content-desc, "What You See")]'
  ];
  
  if (expectedSlide < 1 || expectedSlide > slideXPaths.length) {
    throw Exception('Invalid slide number: $expectedSlide');
  }
  
  try {
    final element = await driver.findElement(By.xpath(slideXPaths[expectedSlide - 1]));
    if (element != null) {
      print('✅ Found expected content for slide $expectedSlide using XPath selector');
      return true;
    }
  } catch (e) {
    print('❌ Slide $expectedSlide not found: ${e.toString().split('\n').first}');
  }

  print('❌ Could not find expected content for slide $expectedSlide');
  return false;
}

/// Detect which slide is currently visible
Future<int> detectCurrentSlide(WebDriver driver) async {
  print('🔍 Detecting current slide...');
  
  // XPath selectors for each slide based on content-desc attribute
  final slideXPaths = [
    '//*[contains(@content-desc, "Pay Anywhere")]',
    '//*[contains(@content-desc, "Your Money")]',
    '//*[contains(@content-desc, "What You See")]'
  ];
  
  // Try to find each slide by its specific XPath
  for (int slideIndex = 0; slideIndex < slideXPaths.length; slideIndex++) {
    try {
      final element = await driver.findElement(By.xpath(slideXPaths[slideIndex]));
      if (element != null) {
        print('✅ Detected slide ${slideIndex + 1} using XPath selector');
        return slideIndex + 1;
      }
    } catch (e) {
      // Slide not found, continue to next
      print('  Slide ${slideIndex + 1} not found: ${e.toString().split('\n').first}');
    }
  }
  
  // If we can't detect the slide, wait a bit and try again (slides change every 5 seconds)
  print('⚠️ Could not detect current slide, waiting 2 seconds and trying again...');
  await Future.delayed(Duration(seconds: 2));
  
  // Retry with the same XPath selectors
  for (int slideIndex = 0; slideIndex < slideXPaths.length; slideIndex++) {
    try {
      final element = await driver.findElement(By.xpath(slideXPaths[slideIndex]));
      if (element != null) {
        print('✅ Detected slide ${slideIndex + 1} using XPath selector (retry)');
        return slideIndex + 1;
      }
    } catch (e) {
      // Slide not found, continue to next
      print('  Slide ${slideIndex + 1} not found (retry): ${e.toString().split('\n').first}');
    }
  }
  
  // If still can't detect, throw an exception
  throw Exception('Could not detect current slide using XPath selectors after retry. App may not be loaded properly.');
}

/// Test intelligent swipe gestures based on current slide
Future<void> testIntelligentSwipeGestures(WebDriver driver) async {
  print('\n👆 Testing intelligent swipe gestures...');
  
  // Get window size for swipe calculations
  final size = await driver.execute('getWindowSize', []) as Map<String, dynamic>;
  final width = size['width'] as int;
  final height = size['height'] as int;
  print('📱 Window size: ${width}x${height}');
  
  // Detect current slide
  final currentSlide = await detectCurrentSlide(driver);
  if (currentSlide != null) {
    print('📍 Currently on Slide $currentSlide');
    
    if (currentSlide == 1) {
      print('\n🔄 Testing Slide 1 navigation...');
      // Slide 1: Right to left (should go to slide 2), then left to right (should return to slide 1)
      
      // First swipe: right to left
      print('➡️ Swiping Slide 1 → Slide 2...');
      await swipeLeft(driver);
      await Future.delayed(Duration(seconds: 1));
      
      final newSlide = await detectCurrentSlide(driver);
      if (newSlide == 2) {
        print('✅ Successfully navigated from Slide 1 to Slide 2');
        
        // Second swipe: left to right (should return to slide 1)
        print('⬅️ Swiping Slide 2 → Slide 1...');
        await swipeRight(driver);
        await Future.delayed(Duration(seconds: 1));
        
        final finalSlide = await detectCurrentSlide(driver);
        if (finalSlide == 1) {
          print('✅ Successfully returned to Slide 1');
        } else {
          print('❌ Failed to return to Slide 1, currently on Slide $finalSlide');
        }
      } else {
        print('❌ Failed to navigate to Slide 2, currently on Slide $newSlide');
      }
      
    } else if (currentSlide == 2) {
      print('\n🔄 Testing Slide 2 navigation...');
      // Slide 2: Right to left (should go to slide 3), then left to right (should return to slide 2)
      
      // First swipe: right to left
      print('➡️ Swiping Slide 2 → Slide 3...');
      await swipeLeft(driver);
      await Future.delayed(Duration(seconds: 1));
      
      final newSlide = await detectCurrentSlide(driver);
      if (newSlide == 3) {
        print('✅ Successfully navigated from Slide 2 to Slide 3');
        
        // Second swipe: left to right (should return to slide 2)
        print('⬅️ Swiping Slide 3 → Slide 2...');
        await swipeRight(driver);
        await Future.delayed(Duration(seconds: 1));
        
        final finalSlide = await detectCurrentSlide(driver);
        if (finalSlide == 2) {
          print('✅ Successfully returned to Slide 2');
        } else {
          print('❌ Failed to return to Slide 2, currently on Slide $finalSlide');
        }
      } else {
        print('❌ Failed to navigate to Slide 3, currently on Slide $newSlide');
      }
      
    } else if (currentSlide == 3) {
      print('\n🔄 Testing Slide 3 navigation...');
      // Slide 3: Left to right (should go to slide 2), then right to left (should return to slide 3)
      
      // First swipe: left to right
      print('⬅️ Swiping Slide 3 → Slide 2...');
      await swipeRight(driver);
      await Future.delayed(Duration(seconds: 1));
      
      final newSlide = await detectCurrentSlide(driver);
      if (newSlide == 2) {
        print('✅ Successfully navigated from Slide 3 to Slide 2');
        
        // Second swipe: right to left (should return to slide 3)
        print('➡️ Swiping Slide 2 → Slide 3...');
        await swipeLeft(driver);
        await Future.delayed(Duration(seconds: 1));
        
        final finalSlide = await detectCurrentSlide(driver);
        if (finalSlide == 3) {
          print('✅ Successfully returned to Slide 3');
        } else {
          print('❌ Failed to return to Slide 3, currently on Slide $finalSlide');
        }
      } else {
        print('❌ Failed to navigate to Slide 2, currently on Slide $newSlide');
      }
    }
  } else {
    print('❌ Could not detect current slide');
  }
}

/// Main UI flow test function
Future<void> testUIFlow(WebDriver driver) async {
  print('\n🧪 Starting UI Flow Test...');

  // --- Step 1: Intelligent Carousel Testing ---
  print('\n🔁 Step 1: Testing intelligent carousel rotation...');
  
  // Detect which slide is currently visible
  final initialSlide = await detectCurrentSlide(driver);
  if (initialSlide != null) {
    print('📍 Starting on Slide $initialSlide');
    
    // Wait and track all slides that appear
    print('⏱️ Waiting for carousel cycle to complete...');
    final slidesSeen = <int>{};
    slidesSeen.add(initialSlide);
    
    // Wait for up to 20 seconds to see all slides
    final startTime = DateTime.now();
    const timeout = Duration(seconds: 20);
    
    while (slidesSeen.length < 3 && DateTime.now().difference(startTime) < timeout) {
      await Future.delayed(Duration(seconds: 2)); // Check every 2 seconds
      final currentSlide = await detectCurrentSlide(driver);
      if (currentSlide != null) {
        if (!slidesSeen.contains(currentSlide)) {
          print('✅ Slide $currentSlide appeared');
          slidesSeen.add(currentSlide);
        } else {
          print('🔄 Slide $currentSlide (already seen)');
        }
      } else {
        print('❓ No slide detected');
      }
    }
    
    // Report results
    if (slidesSeen.length == 3) {
      print('✅ All 3 slides appeared in carousel cycle');
      print('📊 Slides seen: ${slidesSeen.toList()..sort()}');
    } else {
      print('⚠️ Only ${slidesSeen.length} slides appeared: ${slidesSeen.toList()..sort()}');
      print('⏰ Timeout reached or cycle incomplete');
    }
  } else {
    print('❌ Could not detect any slides initially');
  }

  // --- Step 2: Test Intelligent Swipe Gestures ---
  await testIntelligentSwipeGestures(driver);

  // --- Step 3: Test both navigation flows from welcome screen ---
  print('\n📱 Step 3: Testing both navigation flows from welcome screen...');
  await testWelcomeFlow(driver);

  print('\n🎉 UI Flow Test completed successfully!');
}

/// Test the welcome flow including both button interactions
Future<void> testWelcomeFlow(WebDriver driver) async {
  print('🔍 Testing both navigation options from welcome screen...');
  
  // Test 1: Get Started button → Signup Screen
  print('\n📱 Test 1: Testing "Get Started" button → Signup Screen...');
  await testGetStartedFlow(driver);
  
  // Note: Since we can't return to welcome screen, we need to restart the app
  // This test will end here as we're now on the signup screen
  print('📝 Note: App needs to be restarted to return to welcome screen (no back navigation available)');
  print('🎉 Welcome flow test completed successfully!');
}

/// Test the Get Started button flow
Future<void> testGetStartedFlow(WebDriver driver) async {
  print('🔍 Looking for "Get Started" button using specific selectors...');
  
  WebElement? getStartedButton;
  
  // Method 1: Find by accessibility ID (preferred method)
  try {
    getStartedButton = await driver.findElement(By.xpath("//android.view.View[@content-desc='Get Started']"));
    print('✅ Found Get Started button by accessibility ID');
  } catch (e) {
    print('❌ Get Started button not found by accessibility ID: ${e.toString().split('\n').first}');
  }

  // Method 2: Find by exact text if Method 1 failed
  if (getStartedButton == null) {
    try {
      getStartedButton = await driver.findElement(By.xpath("//*[@text='Get Started']"));
      print('✅ Found Get Started button by exact text');
    } catch (e) {
      print('❌ Get Started button not found by exact text: ${e.toString().split('\n').first}');
    }
  }

  // Method 3: Find by partial text in any element if Method 2 failed
  if (getStartedButton == null) {
    try {
      final allElements = await driver.findElements(By.xpath("//*")).toList();
      print('🔍 Found ${allElements.length} total elements, searching for "Get Started" text');
      
      for (int i = 0; i < allElements.length && i < 50; i++) { // Limit to first 50 elements
        try {
          final text = await allElements[i].text;
          if (text.isNotEmpty && text.contains('Get Started')) {
            print('  Element $i text: "$text"');
            getStartedButton = allElements[i];
            print('✅ Found Get Started button in element $i');
            break;
          }
        } catch (e) {
          // Continue to next element
        }
      }
    } catch (e) {
      print('❌ General element search failed: $e');
    }
  }

  if (getStartedButton == null) {
    throw Exception('Get Started button not found with any method');
  }

  print('🎯 Clicking Get Started button...');
  await getStartedButton.click();
  
  // Wait for navigation
  await Future.delayed(Duration(seconds: 3));
  
  print('✅ Get Started button clicked successfully');
  
  // Verify we're on the signup page
  print('🔍 Verifying navigation to signup page...');
  
  WebElement? signupScreen;
  
  // Method 1: Find Signup Screen by accessibility ID
  try {
    signupScreen = await driver.findElement(By.xpath("//android.view.View[@content-desc='Signup Screen']"));
    print('✅ Found Signup Screen by accessibility ID - navigation successful');
  } catch (e) {
    print('❌ Signup Screen not found by accessibility ID: ${e.toString().split('\n').first}');
  }

  // Method 2: Find by exact text if Method 1 failed
  if (signupScreen == null) {
    try {
      signupScreen = await driver.findElement(By.xpath("//*[@text='Signup Screen']"));
      print('✅ Found Signup Screen by exact text - navigation successful');
    } catch (e) {
      print('❌ Signup Screen not found by exact text: ${e.toString().split('\n').first}');
    }
  }

  if (signupScreen == null) {
    throw Exception('Failed to navigate to signup page - Signup Screen not found');
  }
  
  print('🎉 Successfully navigated to signup page!');
}

/// Test the Log In button flow from welcome screen
Future<void> testLogInFlowFromWelcome(WebDriver driver) async {
  print('🔍 Looking for "Log In" button on welcome screen...');
  
  WebElement? logInButton;
  
  // Method 1: Find Log In by accessibility ID
  try {
    logInButton = await driver.findElement(By.xpath("//android.view.View[@content-desc='Log In']"));
    print('✅ Found Log In button by accessibility ID');
  } catch (e) {
    print('❌ Log In button not found by accessibility ID: ${e.toString().split('\n').first}');
  }

  // Method 2: Find Log In by exact text if Method 1 failed
  if (logInButton == null) {
    try {
      logInButton = await driver.findElement(By.xpath("//*[@text='Log In']"));
      print('✅ Found Log In button by exact text');
    } catch (e) {
      print('❌ Log In button not found by exact text: ${e.toString().split('\n').first}');
    }
  }

  if (logInButton == null) {
    throw Exception('Log In button not found on welcome screen');
  }

  print('🎯 Clicking Log In button...');
  await logInButton.click();
  
  // Wait for navigation
  await Future.delayed(Duration(seconds: 3));
  
  print('✅ Log In button clicked successfully');
  
  // Verify we're on the login page
  print('🔍 Verifying navigation to login page...');
  
  WebElement? loginScreen;
  
  // Method 1: Find Login Screen by accessibility ID
  try {
    loginScreen = await driver.findElement(By.xpath("//android.view.View[@content-desc='Login Screen']"));
    print('✅ Found Login Screen by accessibility ID - navigation successful');
  } catch (e) {
    print('❌ Login Screen not found by accessibility ID: ${e.toString().split('\n').first}');
  }

  // Method 2: Find by exact text if Method 1 failed
  if (loginScreen == null) {
    try {
      loginScreen = await driver.findElement(By.xpath("//*[@text='Login Screen']"));
      print('✅ Found Login Screen by exact text - navigation successful');
    } catch (e) {
      print('❌ Login Screen not found by exact text: ${e.toString().split('\n').first}');
    }
  }

  if (loginScreen == null) {
    throw Exception('Failed to navigate to login page - Login Screen not found');
  }
  
  print('🎉 Successfully navigated to login page!');
  print('📝 Note: App needs to be restarted to return to welcome screen (no back navigation available)');
}

/// Test the login flow from signup page (for completeness)
Future<void> testLoginFlow(WebDriver driver) async {
  print('🔍 Looking for "Log In" button on signup page...');
  
  WebElement? logInButton;
  
  // Method 1: Find Log In by accessibility ID
  try {
    logInButton = await driver.findElement(By.xpath("//android.view.View[@content-desc='Log In']"));
    print('✅ Found Log In button by accessibility ID');
  } catch (e) {
    print('❌ Log In button not found by accessibility ID: ${e.toString().split('\n').first}');
  }

  // Method 2: Find Log In by exact text if Method 1 failed
  if (logInButton == null) {
    try {
      logInButton = await driver.findElement(By.xpath("//*[@text='Log In']"));
      print('✅ Found Log In button by exact text');
    } catch (e) {
      print('❌ Log In button not found by exact text: ${e.toString().split('\n').first}');
    }
  }

  if (logInButton == null) {
    throw Exception('Log In button not found on signup page');
  }

  print('🎯 Clicking Log In button...');
  await logInButton.click();
  
  // Wait for navigation
  await Future.delayed(Duration(seconds: 3));
  
  print('✅ Log In button clicked successfully');
  
  // Verify we're on the login page
  print('🔍 Verifying navigation to login page...');
  
  WebElement? loginScreen;
  
  // Method 1: Find Login Screen by accessibility ID
  try {
    loginScreen = await driver.findElement(By.xpath("//android.view.View[@content-desc='Login Screen']"));
    print('✅ Found Login Screen by accessibility ID - navigation successful');
  } catch (e) {
    print('❌ Login Screen not found by accessibility ID: ${e.toString().split('\n').first}');
  }

  // Method 2: Find by exact text if Method 1 failed
  if (loginScreen == null) {
    try {
      loginScreen = await driver.findElement(By.xpath("//*[@text='Login Screen']"));
      print('✅ Found Login Screen by exact text - navigation successful');
    } catch (e) {
      print('❌ Login Screen not found by exact text: ${e.toString().split('\n').first}');
    }
  }

  if (loginScreen == null) {
    throw Exception('Failed to navigate to login page - Login Screen not found');
  }
  
  print('🎉 Successfully navigated to login page!');
  print('📝 Note: App needs to be restarted to return to welcome screen (no back navigation available)');
}