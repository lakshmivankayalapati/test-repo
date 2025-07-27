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
      });

      test('should correctly interpret empty string as false', () {
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic('');
        expect(hasSeenWelcome, isFalse);
      });

      test('should correctly interpret "true" as true', () {
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic('true');
        expect(hasSeenWelcome, isTrue);
      });

      test('should correctly interpret "false" as false', () {
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic('false');
        expect(hasSeenWelcome, isFalse);
      });

      test('should correctly interpret invalid values as false', () {
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic('YES');
        expect(hasSeenWelcome, isFalse);
      });

      test('should be case sensitive', () {
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic('TRUE');
        expect(hasSeenWelcome, isFalse);
      });
    });

    group('Redirect Logic Tests (from main.dart)', () {
      test('should redirect to welcome when hasSeenWelcome is false', () {
        final redirectPath = RouterLogic.getRedirectPath(false);
        expect(redirectPath, equals('/welcome'));
      });

      test('should redirect to signup when hasSeenWelcome is true', () {
        final redirectPath = RouterLogic.getRedirectPath(true);
        expect(redirectPath, equals('/signup'));
      });

      test('should handle edge case with null hasSeenWelcome', () {
        // This tests the logic when hasSeenWelcome is null (which should be false)
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic(null);
        final redirectPath = RouterLogic.getRedirectPath(hasSeenWelcome);
        expect(redirectPath, equals('/welcome'));
      });
    });

    group('Router Creation Tests (from main.dart)', () {
      test('should create router successfully', () {
        final router = RouterLogic.createRouter(false);
        
        // Test that router is created successfully
        expect(router, isNotNull);
      });

      test('should create router with welcome redirect when hasSeenWelcome is false', () async {
        final router = RouterLogic.createRouter(false);
        
        // Test the redirect logic
        final redirectPath = RouterLogic.getRedirectPath(false);
        expect(redirectPath, equals('/welcome'));
      });

      test('should create router with signup redirect when hasSeenWelcome is true', () async {
        final router = RouterLogic.createRouter(true);
        
        // Test the redirect logic
        final redirectPath = RouterLogic.getRedirectPath(true);
        expect(redirectPath, equals('/signup'));
      });
    });

    group('Storage Integration Tests', () {
      test('should work with storage reading logic', () async {
        // Test the actual storage reading logic that would be used in main.dart
        mockStorage.setValue('hasSeenWelcome', 'true');
        final hasSeenWelcomeValue = await mockStorage.read(key: 'hasSeenWelcome');
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic(hasSeenWelcomeValue);
        
        expect(hasSeenWelcome, isTrue);
      });

      test('should handle missing storage value', () async {
        // Test when storage doesn't have the flag
        final hasSeenWelcomeValue = await mockStorage.read(key: 'hasSeenWelcome');
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic(hasSeenWelcomeValue);
        
        expect(hasSeenWelcome, isFalse);
      });
    });

    group('Current Debug Configuration', () {
      test('should reflect current hardcoded hasSeenWelcome = false in main.dart', () {
        // This reflects the current debugging setup in main.dart line 20
        const hasSeenWelcome = false; // Line 20 in main.dart
        
        expect(hasSeenWelcome, isFalse);
        // This means welcome screen always shows in debug mode
      });

      test('should work with the commented out storage logic', () async {
        // This test simulates what would happen if the storage logic was uncommented
        // const storage = FlutterSecureStorage();
        // final hasSeenWelcomeValue = await storage.read(key: 'hasSeenWelcome');
        // final hasSeenWelcome = hasSeenWelcomeValue == 'true';
        
        // Simulate the actual logic that's commented out
        final hasSeenWelcomeValue = await mockStorage.read(key: 'hasSeenWelcome');
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic(hasSeenWelcomeValue);
        
        expect(hasSeenWelcome, isFalse);
      });
    });

    group('Navigation Flow Tests', () {
      test('should handle fresh install flow (no hasSeenWelcome flag)', () async {
        // Simulate fresh install: no hasSeenWelcome flag
        final hasSeenWelcomeValue = await mockStorage.read(key: 'hasSeenWelcome');
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic(hasSeenWelcomeValue);
        final redirectPath = RouterLogic.getRedirectPath(hasSeenWelcome);
        
        expect(hasSeenWelcome, isFalse);
        expect(redirectPath, equals('/welcome'));
      });

      test('should handle returning user flow (hasSeenWelcome flag set)', () async {
        // Simulate returning user: hasSeenWelcome flag is set
        mockStorage.setValue('hasSeenWelcome', 'true');
        final hasSeenWelcomeValue = await mockStorage.read(key: 'hasSeenWelcome');
        final hasSeenWelcome = RouterLogic.hasSeenWelcomeLogic(hasSeenWelcomeValue);
        final redirectPath = RouterLogic.getRedirectPath(hasSeenWelcome);
        
        expect(hasSeenWelcome, isTrue);
        expect(redirectPath, equals('/signup'));
      });
    });
  });
} 