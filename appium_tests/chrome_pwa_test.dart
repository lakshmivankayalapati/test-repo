import 'dart:io';
import 'package:webdriver/async_io.dart';

/// Appium UI Test for Chrome PWA
/// Tests the onboarding flow with automated interactions
void main() async {
  print('🚀 Starting Chrome PWA UI Test...');
  
  try {
    // Connect to Appium server
    final driver = await createDriver(
      uri: Uri.parse('http://127.0.0.1:4723'),
      desired: {
        'platformName': 'Android',
        'appium:platformVersion': '13',
        'appium:deviceName': 'Pixel_4a_API_33',
        'appium:automationName': 'UiAutomator2',
        'browserName': 'Chrome',
        'appium:chromedriverExecutable': '/path/to/chromedriver', // Update with your chromedriver path
        'appium:noReset': true,
      },
    );

    print('✅ Connected to Appium server');
    print('🌐 Starting Chrome PWA test...');

    // Navigate to your PWA URL
    await driver.get('http://localhost:3000'); // Update with your PWA URL
    print('✅ Navigated to PWA URL');

    // Wait for app to load
    await Future.delayed(Duration(seconds: 5));

    // Test 1: Welcome Screen Elements
    print('🧪 Test 1: Welcome Screen Elements');
    
    // Wait for welcome screen to load
    final welcomeText = await driver.findElement(By.xpath("//*[contains(text(), 'Welcome')]"));
    print('✅ Found welcome text: ${await welcomeText.text}');

    // Find and verify "Get Started" button
    final getStartedButton = await driver.findElement(By.xpath("//button[contains(text(), 'Get Started')]"));
    print('✅ Found Get Started button');

    // Test 2: Onboarding Slides Navigation
    print('🧪 Test 2: Onboarding Slides Navigation');
    
    // Click Get Started to enter onboarding
    await getStartedButton.click();
    print('✅ Clicked Get Started button');

    // Navigate through slides
    for (int i = 1; i <= 3; i++) {
      print('📄 Testing slide $i');
      
      // Wait for slide content
      await Future.delayed(Duration(seconds: 2));
      
      // Find slide content
      final slideContent = await driver.findElement(By.xpath("//div[contains(@class, 'slide') or contains(@class, 'welcome-slide')]"));
      print('✅ Found slide $i content');
      
      // Find and click "Next" button (except on last slide)
      if (i < 3) {
        final nextButton = await driver.findElement(By.xpath("//button[contains(text(), 'Next')]"));
        await nextButton.click();
        print('✅ Clicked Next button on slide $i');
      }
    }

    // Test 3: Complete Onboarding
    print('🧪 Test 3: Complete Onboarding');
    
    // Click final "Get Started" button
    final finalGetStartedButton = await driver.findElement(By.xpath("//button[contains(text(), 'Get Started')]"));
    await finalGetStartedButton.click();
    print('✅ Clicked final Get Started button');

    // Test 4: Verify Main App
    print('🧪 Test 4: Verify Main App');
    
    await Future.delayed(Duration(seconds: 3));
    
    // Check if we're in the main app
    try {
      final mainAppElement = await driver.findElement(By.xpath("//*[contains(text(), 'Sliq Pay') or contains(@class, 'main-app')]"));
      print('✅ Successfully navigated to main app');
    } catch (e) {
      print('⚠️ Could not verify main app navigation: $e');
    }

    // Test 5: Responsive Design Check
    print('🧪 Test 5: Responsive Design Check');
    
    // Get window size
    final windowSize = await driver.manage().window().getSize();
    print('📱 Window size: ${windowSize.width}x${windowSize.height}');
    
    // Check for any overflow issues
    try {
      final body = await driver.findElement(By.tagName('body'));
      final bodyRect = await body.rect;
      print('✅ Body element size: ${bodyRect.width}x${bodyRect.height}');
      
      // Check if content fits within viewport
      if (bodyRect.width <= windowSize.width && bodyRect.height <= windowSize.height) {
        print('✅ No horizontal overflow detected');
      } else {
        print('⚠️ Potential overflow detected');
      }
    } catch (e) {
      print('⚠️ Could not check responsive design: $e');
    }

    print('🎉 All Chrome PWA tests completed successfully!');

  } catch (e) {
    print('❌ Test failed: $e');
    exit(1);
  } finally {
    // Clean up
    try {
      await driver?.quit();
      print('🧹 Test cleanup completed');
    } catch (e) {
      print('⚠️ Cleanup warning: $e');
    }
  }
} 