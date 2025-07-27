import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:go_router/go_router.dart';
import 'package:sliq_pay/core/analytics/analytics_service.dart';
import 'package:sliq_pay/core/services/connectivity_service.dart';
import 'package:sliq_pay/core/utils/toast_utils.dart';
import 'package:sliq_pay/features/onboarding/presentation/widgets/bar_page_indicator.dart';
import 'package:sliq_pay/features/onboarding/presentation/widgets/cut_corner_button.dart';
import 'package:sliq_pay/features/onboarding/presentation/widgets/welcome_slide.dart';
import 'package:sliq_pay/src/localization/gen/app_localizations.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  Timer? _timer;
  bool _reduceMotion = false;
  bool _timerInitialized = false;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      final newPage = _pageController.page?.round() ?? 0;
      if (newPage != _currentPage) {
        ref
            .read(analyticsServiceProvider)
            .trackEvent(
              name: 'welcome_swipe',
              parameters: {'from_page': _currentPage, 'to_page': newPage},
            );
        setState(() {
          _currentPage = newPage;
        });

        if (newPage == 2) {
          _setHasSeenWelcome();
        }
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_timerInitialized) {
      _reduceMotion = MediaQuery.of(context).disableAnimations;
      if (!_reduceMotion) {
        _startTimer();
      }
      _timerInitialized = true;
      ref.read(analyticsServiceProvider).trackEvent(name: 'welcome_impression');
    }
  }

  Future<void> _setHasSeenWelcome() async {
    const storage = FlutterSecureStorage();
    await storage.write(key: 'hasSeenWelcome', value: 'true');
  }

  void _onGetStarted() async {
    final isConnected = await ref
        .read(connectivityServiceProvider)
        .isConnected();
    if (!isConnected) {
      showToast('No internet connection');
      return;
    }
    ref.read(analyticsServiceProvider).trackEvent(name: 'cta_get_started');
    await _setHasSeenWelcome();
    if (mounted) {
      context.go('/signup');
    }
  }

  void _onLogin() async {
    final isConnected = await ref
        .read(connectivityServiceProvider)
        .isConnected();
    if (!isConnected) {
      showToast('No internet connection');
      return;
    }
    ref.read(analyticsServiceProvider).trackEvent(name: 'cta_login');
    context.go('/login');
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (!_pageController.hasClients) return;

      if (_currentPage < 2) {
        _pageController.nextPage(
          duration: const Duration(milliseconds: 800),
          curve: Curves.easeInOutCubic,
        );
      } else {
        _pageController.animateToPage(
          0,
          duration: const Duration(milliseconds: 1000),
          curve: Curves.easeInOutCubic,
        );
      }
    });
  }

  void _resetTimer() {
    _timer?.cancel();
    if (!_reduceMotion) {
      _startTimer();
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    const figmaScreenHeight = 812.0;
    const figmaScreenWidth = 375.0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                20.0 * (screenWidth / figmaScreenWidth),
                16.0 * (screenHeight / figmaScreenHeight),
                20.0 * (screenWidth / figmaScreenWidth),
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Image.asset(
                    'assets/images/logo.png',
                    height: screenWidth * (34 / figmaScreenWidth),
                  ),
                  BarPageIndicator(currentIndex: _currentPage, pageCount: 3),
                ],
              ),
            ),
            Expanded(
              child: Listener(
                onPointerDown: (_) => _timer?.cancel(),
                onPointerUp: (_) => _resetTimer(),
                child: PageView(
                  controller: _pageController,
                  children: [
                    WelcomeSlide(
                      isActive: _currentPage == 0,
                      image: 'assets/images/welcome_screen_1.png',
                      title: AppLocalizations.of(context)!.welcomeScreenTitle1,
                      description: AppLocalizations.of(
                        context,
                      )!.welcomeScreenDescription1,
                    ),
                    WelcomeSlide(
                      isActive: _currentPage == 1,
                      image: 'assets/images/welcome_screen_2.png',
                      title: AppLocalizations.of(context)!.welcomeScreenTitle2,
                      description: AppLocalizations.of(
                        context,
                      )!.welcomeScreenDescription2,
                    ),
                    WelcomeSlide(
                      isActive: _currentPage == 2,
                      image: 'assets/images/welcome_screen_3.png',
                      title: AppLocalizations.of(context)!.welcomeScreenTitle3,
                      description: AppLocalizations.of(
                        context,
                      )!.welcomeScreenDescription3,
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 20.0 * (screenWidth / figmaScreenWidth)),
              child: Column(
                children: [
                  CutCornerButton(
                    height: screenWidth * (48 / figmaScreenWidth),
                    onPressed: _onGetStarted,
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF252525),
                        Color(0xFF636262),
                        Color(0xFF292929),
                      ],
                    ),
                    cornersToClip: const {Corner.topLeft, Corner.bottomRight},
                    child: Text(
                      AppLocalizations.of(context)!.getStarted,
                      style: TextStyle(
                          color: Colors.white,
                          fontSize:
                              18 * (MediaQuery.of(context).size.width / 375),
                          fontWeight: FontWeight.w700),
                    ),
                  ),
                  SizedBox(height: screenWidth * (8 / figmaScreenWidth)),
                  Container(
                    height: screenWidth * (40 / figmaScreenWidth),
                    alignment: Alignment.center,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: TextStyle(
                            fontSize: 14 *
                                (MediaQuery.of(context).size.width / 375),
                          ),
                        ),
                        SizedBox(
                            width:
                                4 * (MediaQuery.of(context).size.width / 375)),
                        GestureDetector(
                          onTap: _onLogin,
                          child: Text(
                            AppLocalizations.of(context)!.login,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 14 *
                                  (MediaQuery.of(context).size.width / 375),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: screenWidth * (20 / figmaScreenWidth)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
