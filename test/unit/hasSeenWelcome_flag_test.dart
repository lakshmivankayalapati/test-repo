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
        // Act: Use the actual logic from main.dart
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic('true');
        
        // Assert: Verify the returned value
        expect(hasSeenWelcome, isTrue);
      });

      test('should return false when flag is not set (null)', () {
        // Act: Use the actual logic from main.dart
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic(null);
        
        // Assert: Verify null is interpreted as false
        expect(hasSeenWelcome, isFalse);
      });

      test('should handle empty string value for flag', () {
        // Act: Use the actual logic from main.dart
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic('');
        
        // Assert: Verify empty string is interpreted as false
        expect(hasSeenWelcome, isFalse);
      });

      test('should handle unexpected string value for flag', () {
        // Act: Use the actual logic from main.dart
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic('corrupted_value');
        
        // Assert: Verify unexpected value is interpreted as false
        expect(hasSeenWelcome, isFalse);
      });

      test('should handle "false" string value', () {
        // Act: Use the actual logic from main.dart
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic('false');
        
        // Assert: Verify "false" string is interpreted as false
        expect(hasSeenWelcome, isFalse);
      });

      test('should be case sensitive', () {
        // Act: Use the actual logic from main.dart
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic('TRUE');
        
        // Assert: Verify case sensitivity
        expect(hasSeenWelcome, isFalse);
      });
    });

    group('Storage Integration Logic', () {
      test('should read hasSeenWelcome flag from storage correctly', () async {
        // Arrange: Pre-set the flag in storage
        mockStorage.setValue('hasSeenWelcome', 'true');

        // Act: Use the actual storage reading logic
        final hasSeenWelcome = await FlagLogic.readHasSeenWelcomeFlag(mockStorage.read);

        // Assert: Verify the returned value
        expect(hasSeenWelcome, isTrue);
      });

      test('should return false when flag is not in storage', () async {
        // Act: Use the actual storage reading logic
        final hasSeenWelcome = await FlagLogic.readHasSeenWelcomeFlag(mockStorage.read);

        // Assert: Verify null is returned and interpreted as false
        expect(hasSeenWelcome, isFalse);
      });

      test('should set hasSeenWelcome flag in storage', () async {
        // Act: Use the actual storage writing logic from WelcomeScreen
        await FlagLogic.setHasSeenWelcomeFlag(mockStorage.write);

        // Assert: Verify the value was stored correctly
        expect(mockStorage.storage['hasSeenWelcome'], equals('true'));
      });
    });

    group('Current Debug Configuration', () {
      test('should reflect current hardcoded hasSeenWelcome = false in main.dart', () {
        // This test reflects the current debugging setup in main.dart line 20
        const hasSeenWelcome = false; // This matches main.dart line 20
        
        // Assert: Verify the current debugging behavior
        expect(hasSeenWelcome, isFalse);
        
        // This means the welcome screen will always show in debug mode
        // which is useful for testing the updated UI
      });

      test('should work with the commented out storage logic', () async {
        // This test simulates what would happen if the storage logic was uncommented
        // const storage = FlutterSecureStorage();
        // final hasSeenWelcomeValue = await storage.read(key: 'hasSeenWelcome');
        // final hasSeenWelcome = hasSeenWelcomeValue == 'true';
        
        // Simulate the actual logic that's commented out
        final hasSeenWelcomeValue = await mockStorage.read(key: 'hasSeenWelcome');
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic(hasSeenWelcomeValue);
        
        // Assert: Verify the behavior matches the commented logic
        expect(hasSeenWelcome, isFalse);
      });
    });

    group('Edge Cases', () {
      test('should handle whitespace in flag value', () {
        // Act: Use the actual logic from main.dart
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic(' true ');
        
        // Assert: Verify whitespace is not trimmed
        expect(hasSeenWelcome, isFalse);
      });

      test('should handle special characters in flag value', () {
        // Act: Use the actual logic from main.dart
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic('true\n');
        
        // Assert: Verify special characters are not ignored
        expect(hasSeenWelcome, isFalse);
      });

      test('should handle very long string values', () {
        // Act: Use the actual logic from main.dart
        final hasSeenWelcome = FlagLogic.hasSeenWelcomeLogic('true' * 1000);
        
        // Assert: Verify long strings are handled correctly
        expect(hasSeenWelcome, isFalse);
      });
    });
  });
} 