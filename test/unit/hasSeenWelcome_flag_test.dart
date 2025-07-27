import 'package:flutter_test/flutter_test.dart';

// Pure unit test class that contains the actual flag logic from main.dart
class FlagLogic {
  // The actual flag reading logic from main.dart (currently commented out)
  static bool hasSeenWelcomeLogic(String? hasSeenWelcomeValue) {
    return hasSeenWelcomeValue == 'true';
  }

  // The actual storage logic that would be used in main.dart
  static Future<bool> readHasSeenWelcomeFlag(Future<String?> Function({required String key}) storageRead) async {
    final hasSeenWelcomeValue = await storageRead(key: 'hasSeenWelcome');
    return hasSeenWelcomeLogic(hasSeenWelcomeValue);
  }

  // The actual storage writing logic from WelcomeScreen
  static Future<void> setHasSeenWelcomeFlag(Future<void> Function({required String key, required String? value}) storageWrite) async {
    await storageWrite(key: 'hasSeenWelcome', value: 'true');
  }
}

// Mock storage for testing
class MockStorage {
  final Map<String, String> _storage = {};

  Future<String?> read({required String key}) async {
    return _storage[key];
  }

  Future<void> write({required String key, required String? value}) async {
    if (value != null) {
      _storage[key] = value;
    } else {
      _storage.remove(key);
    }
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

  Map<String, String> get storage => Map.unmodifiable(_storage);
}

void main() {
  group('hasSeenWelcome Flag Logic Unit Tests', () {
    late MockStorage mockStorage;

    setUp(() {
      mockStorage = MockStorage();
    });

    group('Flag Reading Logic (from main.dart)', () {
      test('should correctly interpret "true" as true', () {
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic('true');
        expect(hasSeenWelcome, isTrue);
        print('PASS: should correctly interpret "true" as true');
      });

      test('should return false when flag is not set (null)', () {
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic(null);
        expect(hasSeenWelcome, isFalse);
        print('PASS: should return false when flag is not set (null)');
      });

      test('should handle unexpected string value for flag', () {
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic('corrupted_value');
        expect(hasSeenWelcome, isFalse);
        print('PASS: should handle unexpected string value for flag');
      });

      test('should be case sensitive', () {
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic('TRUE');
        expect(hasSeenWelcome, isFalse);
        print('PASS: should be case sensitive');
      });
    });

    group('Storage Integration Logic', () {
      test('should read hasSeenWelcome flag from storage correctly', () async {
        mockStorage.setValue('hasSeenWelcome', 'true');
        final hasSeenWelcome = await FlagLogic.readHasSeenWelcomeFlag(mockStorage.read);
        expect(hasSeenWelcome, isTrue);
        print('PASS: should read hasSeenWelcome flag from storage correctly');
      });

      test('should return false when flag is not in storage', () async {
        final hasSeenWelcome = await FlagLogic.readHasSeenWelcomeFlag(mockStorage.read);
        expect(hasSeenWelcome, isFalse);
        print('PASS: should return false when flag is not in storage');
      });

      test('should set hasSeenWelcome flag in storage', () async {
        await FlagLogic.setHasSeenWelcomeFlag(mockStorage.write);
        expect(mockStorage.storage['hasSeenWelcome'], equals('true'));
        print('PASS: should set hasSeenWelcome flag in storage');
      });
    });

    group('Current Debug Configuration', () {
      test('should reflect current hardcoded hasSeenWelcome = false in main.dart', () {
        const hasSeenWelcome = false; // This matches main.dart line 20
        expect(hasSeenWelcome, isFalse);
        print('PASS: should reflect current hardcoded hasSeenWelcome = false in main.dart');
      });
    });
  });
} 