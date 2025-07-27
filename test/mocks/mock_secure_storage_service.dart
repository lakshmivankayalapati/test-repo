import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Mock FlutterSecureStorage for testing (updated for new UI architecture)
class MockFlutterSecureStorage {
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

  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  Future<void> deleteAll() async {
    _storage.clear();
  }

  // Helper methods for testing
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

// Legacy mock for backward compatibility (if needed)
class MockSecureStorageService {
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

  Future<void> delete({required String key}) async {
    _storage.remove(key);
  }

  Future<void> deleteAll() async {
    _storage.clear();
  }

  // Helper methods for testing
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

// Provider override for testing (updated for new architecture)
final mockFlutterSecureStorageProvider = Provider<MockFlutterSecureStorage>((ref) {
  return MockFlutterSecureStorage();
});

// Legacy provider for backward compatibility
final mockSecureStorageProvider = Provider<MockSecureStorageService>((ref) {
  return MockSecureStorageService();
}); 