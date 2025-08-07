import 'dart:async'; // For Timer
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // For rootBundle
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart'; // For context.go
import 'package:golden_toolkit/golden_toolkit.dart'; // For screenMatchesGolden, loadAppFonts
import 'package:google_fonts/google_fonts.dart'; // For GoogleFonts.config

// --- Core App Service Imports ---
import 'package:sliq_pay/features/onboarding/presentation/widgets/bar_page_indicator.dart';
import 'package:sliq_pay/features/onboarding/presentation/widgets/cut_corner_button.dart';
import 'package:sliq_pay/features/onboarding/presentation/widgets/welcome_slide.dart';
import 'package:sliq_pay/src/localization/gen/app_localizations.dart';

// --- Test Screen Sizes ---
const Size smallPhone = Size(320, 568); // iPhone 5/SE
const Size mediumPhone = Size(390, 844); // iPhone 12/13/14 Pro
const Size tablet = Size(768, 1024); // iPad Mini / small tablet

// --- Simple TestableWelcomeScreen (Using Actual WelcomeSlide) ---
class SimpleTestableWelcomeScreen extends StatelessWidget {
  final int initialPage; // For testing specific initial slides

  const SimpleTestableWelcomeScreen({super.key, this.initialPage = 0});

  @override
  Widget build(BuildContext context) {
    // Ensure AppLocalizations is not null before accessing properties
    final l10n = AppLocalizations.of(context)!; // Assert non-null

    // List of welcome slide data
    final List<Map<String, String>> slides = [
      {
        'image': 'assets/images/welcome_screen_1.png',
        'title': l10n.welcomeScreenTitle1,
        'description': l10n.welcomeScreenDescription1,
      },
      {
        'image': 'assets/images/welcome_screen_2.png',
        'title': l10n.welcomeScreenTitle2,
        'description': l10n.welcomeScreenDescription2,
      },
      {
        'image': 'assets/images/welcome_screen_3.png',
        'title': l10n.welcomeScreenTitle3,
        'description': l10n.welcomeScreenDescription3,
      },
    ];

    // Get the specific slide data
    final slideData = slides[initialPage];

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and page indicator
            Padding(
              padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: 34,
                  ),
                  BarPageIndicator(
                    currentIndex: initialPage,
                    pageCount: 3,
                  ),
                ],
              ),
            ),
            // Main content area
            Expanded(
              child: WelcomeSlide(
                isActive: true, // Always active for golden tests
                image: slideData['image']!,
                title: slideData['title']!,
                description: slideData['description']!,
              ),
            ),
            // Bottom buttons
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                children: [
                  CutCornerButton(
                    height: 48,
                    onPressed: () {},
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF252525),
                        Color(0xFF636262),
                        Color(0xFF292929),
                      ],
                    ),
                    cornersToClip: const {Corner.topLeft, Corner.bottomRight},
                    child: Text(
                      l10n.getStarted,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 40,
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account?',
                          style: TextStyle(fontSize: 14),
                        ),
                        const SizedBox(width: 4),
                        GestureDetector(
                          onTap: () {},
                          child: Text(
                            l10n.login,
                            style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// --- Test Wrapper for Golden Tests ---
Widget testAppWrapper({
  required Widget child,
  ThemeData? theme,
}) {
  // Use the actual app theme that includes Malinton font
  final appTheme = ThemeData(
    brightness: Brightness.light,
    scaffoldBackgroundColor: Colors.white,
    colorScheme: const ColorScheme.light(
      primary: Colors.black,
      secondary: Colors.grey,
      surface: Colors.white,
    ),
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Malinton',
        fontWeight: FontWeight.w700,
        fontSize: 32,
        height: 1.25,
        letterSpacing: 0,
      ),
    ),
  );

  return ProviderScope(
    child: MaterialApp(
      debugShowCheckedModeBanner: false, // Remove debug banner from golden images
      theme: theme ?? appTheme,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: child,
    ),
  );
}

void main() {
  // Ensure Flutter test binding is initialized.
  TestWidgetsFlutterBinding.ensureInitialized();

  // Load fonts once for all golden tests.
  setUpAll(() async {
    // Configure google_fonts to not fetch from network during tests.
    GoogleFonts.config.allowRuntimeFetching = false;
    // Load custom fonts if used by your app (e.g., from assets/fonts)
    await loadAppFonts(); // From golden_toolkit package
  });

  group('📸 Golden Tests - WelcomeScreen', () {
    // Helper to run a golden test with overflow detection
    Future<void> runGoldenTestWithOverflowCheck(
      WidgetTester tester,
      Size surfaceSize,
      String goldenFileName,
      int initialPage,
    ) async {
      // Set up a custom error handler to catch RenderFlex overflows
      FlutterError.onError = (FlutterErrorDetails details) {
        if (details.exception.toString().contains('RenderFlex overflowed')) {
          debugPrint('❌ RenderFlex Overflow Detected: ${details.exception.toString()}');
          // Fail the test explicitly if an overflow is detected.
          fail('RenderFlex overflow detected for $goldenFileName at $surfaceSize. This needs to be fixed for accessibility.');
        }
        // Allow other FlutterErrors to be handled by the default handler (or rethrow them)
        FlutterError.dumpErrorToConsole(details);
      };

      await tester.pumpWidgetBuilder(
        SimpleTestableWelcomeScreen(initialPage: initialPage),
        surfaceSize: surfaceSize,
        wrapper: (child) => testAppWrapper(child: child),
      );
      
      // Simple pump and settle for the direct content
      await tester.pumpAndSettle();

      // Generate the golden image
      await screenMatchesGolden(tester, goldenFileName);
      debugPrint('✅ Golden test passed for $goldenFileName at $surfaceSize.');

      // Reset error handler after the test
      FlutterError.onError = FlutterError.dumpErrorToConsole;
    }

    // --- Golden Test Cases for all slides and screen sizes ---

    // Small Phone (320x568)
    testGoldens('Slide 1 - Small Phone (320x568)', (tester) async {
      await runGoldenTestWithOverflowCheck(tester, smallPhone, 'welcome_slide_1_small_phone', 0);
    });
    testGoldens('Slide 2 - Small Phone (320x568)', (tester) async {
      await runGoldenTestWithOverflowCheck(tester, smallPhone, 'welcome_slide_2_small_phone', 1);
    });
    testGoldens('Slide 3 - Small Phone (320x568)', (tester) async {
      await runGoldenTestWithOverflowCheck(tester, smallPhone, 'welcome_slide_3_small_phone', 2);
    });

    // Medium Phone (390x844)
    testGoldens('Slide 1 - Medium Phone (390x844)', (tester) async {
      await runGoldenTestWithOverflowCheck(tester, mediumPhone, 'welcome_slide_1_medium_phone', 0);
    });
    testGoldens('Slide 2 - Medium Phone (390x844)', (tester) async {
      await runGoldenTestWithOverflowCheck(tester, mediumPhone, 'welcome_slide_2_medium_phone', 1);
    });
    testGoldens('Slide 3 - Medium Phone (390x844)', (tester) async {
      await runGoldenTestWithOverflowCheck(tester, mediumPhone, 'welcome_slide_3_medium_phone', 2);
    });

    // Tablet (768x1024)
    testGoldens('Slide 1 - Tablet (768x1024)', (tester) async {
      await runGoldenTestWithOverflowCheck(tester, tablet, 'welcome_slide_1_tablet', 0);
    });
    testGoldens('Slide 2 - Tablet (768x1024)', (tester) async {
      await runGoldenTestWithOverflowCheck(tester, tablet, 'welcome_slide_2_tablet', 1);
    });
    testGoldens('Slide 3 - Tablet (768x1024)', (tester) async {
      await runGoldenTestWithOverflowCheck(tester, tablet, 'welcome_slide_3_tablet', 2);
    });
  });
}