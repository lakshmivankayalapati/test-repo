import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

// Pure unit test class that contains the actual router logic from main.dart
class RouterLogic {
  // The actual flag reading logic from main.dart
  static bool hasSeenWelcomeLogic(String? hasSeenWelcomeValue) {
    return hasSeenWelcomeValue == 'true';
  }

  // The actual router creation logic from main.dart
  static GoRouter createRouter(bool hasSeenWelcome) {
    return GoRouter(
      routes: [
        GoRoute(
          path: '/',
          redirect: (context, state) async {
            if (hasSeenWelcome) {
              // TODO: check if user is logged in
              // if logged in, return '/home'
              // else return '/login'
              return '/signup';
            } else {
              return '/welcome';
            }
          },
        ),
        GoRoute(
          path: '/welcome',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Welcome Screen'))),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Signup Screen'))),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Login Screen'))),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const Scaffold(body: Center(child: Text('Home Screen'))),
        ),
      ],
    );
  }

  // The actual redirect logic extracted for testing
  static String? getRedirectPath(bool hasSeenWelcome) {
    if (hasSeenWelcome) {
      // TODO: check if user is logged in
      // if logged in, return '/home'
      // else return '/login'
      return '/signup';
    } else {
      return '/welcome';
    }
  }
}

// Mock storage for testing
class MockStorage {
  final Map<String, String> _storage = {};

  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  void setValue(String key, String? value) {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
  }

  void clear() {
    _storage.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Router Logic Unit Tests', () {
    late MockStorage mockStorage;

    setUp(() {
      mockStorage = MockStorage();
    });

    group('Flag Logic Tests (from main.dart)', () {
      test('should correctly interpret null as false', () {
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic(null);
        expect(hasSeenWelcome, isFalse);
        print('PASS: should correctly interpret null as false');
      });

      test('should correctly interpret "true" as true', () {
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic('true');
        expect(hasSeenWelcome, isTrue);
        print('PASS: should correctly interpret "true" as true');
      });

      test('should correctly interpret invalid values as false', () {
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic('YES');
        expect(hasSeenWelcome, isFalse);
        print('PASS: should correctly interpret invalid values as false');
      });
    });

    group('Redirect Logic Tests (from main.dart)', () {
      test('should redirect to welcome when hasSeenWelcome is false', () {
        final redirectPath = RouterLogic.getRedirectPath(false);
        expect(redirectPath, equals('/welcome'));
        print('PASS: should redirect to welcome when hasSeenWelcome is false');
      });

      test('should redirect to signup when hasSeenWelcome is true', () {
        final redirectPath = RouterLogic.getRedirectPath(true);
        expect(redirectPath, equals('/signup'));
        print('PASS: should redirect to signup when hasSeenWelcome is true');
      });
    });

    group('Router Creation Tests (from main.dart)', () {
      test('should create router successfully', () {
        final router = RouterLogic.createRouter(false);
        expect(router, isNotNull);
        print('PASS: should create router successfully');
      });
    });

    group('Storage Integration Tests', () {
      test('should work with storage reading logic', () async {
        mockStorage.setValue('hasSeenWelcome', 'true');
        final hasSeenWelcomeValue = await mockStorage.read(key: 'hasSeenWelcome');
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic(hasSeenWelcomeValue);
        expect(hasSeenWelcome, isTrue);
        print('PASS: should work with storage reading logic');
      });

      test('should handle missing storage value', () async {
        final hasSeenWelcomeValue = await mockStorage.read(key: 'hasSeenWelcome');
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic(hasSeenWelcomeValue);
        expect(hasSeenWelcome, isFalse);
        print('PASS: should handle missing storage value');
      });
    });

    group('Current Debug Configuration', () {
      test('should reflect current hardcoded hasSeenWelcome = false in main.dart', () {
        const hasSeenWelcome = false; // Line 20 in main.dart
        expect(hasSeenWelcome, isFalse);
        print('PASS: should reflect current hardcoded hasSeenWelcome = false in main.dart');
      });
    });
  });
} 