import 'dart:async';
import 'package:flutter_test/flutter_test.dart';

// Self-contained timer logic for unit testing
class CarouselTimer {
  Timer? _timer;
  int _currentPage = 0;
  bool _reduceMotion = false;
  final List<String> _actions = [];

  // Getters for testing
  Timer? get timer => _timer;
  int get currentPage => _currentPage;
  bool get reduceMotion => _reduceMotion;
  List<String> get actions => List.unmodifiable(_actions);

  // Setters for testing
  void setCurrentPage(int page) {
    _currentPage = page;
  }

  void setReduceMotion(bool value) {
    _reduceMotion = value;
  }

  // Timer logic
  void startTimer() {
    if (_reduceMotion) return;
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (_currentPage < 2) {
        _actions.add('nextPage');
        _currentPage++;
      } else {
        _actions.add('animateToPage:0');
        _currentPage = 0;
      }
    });
  }

  void resetTimer() {
    _timer?.cancel();
    _timer = null;
    if (!_reduceMotion) {
      startTimer();
    }
  }

  void dispose() {
    _timer?.cancel();
    _timer = null;
  }
}

void main() {
  group('Carousel Timer Logic Unit Tests', () {
    late CarouselTimer carouselTimer;

    setUp(() {
      carouselTimer = CarouselTimer();
    });

    tearDown(() {
      carouselTimer.dispose();
    });

    test('should create timer when reduceMotion is false', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      expect(carouselTimer.timer, isNotNull);
      expect(carouselTimer.timer!.isActive, isTrue);
      print('PASS: should create timer when reduceMotion is false');
    });

    test('should not create timer when reduceMotion is true', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(true);
      carouselTimer.startTimer();
      expect(carouselTimer.timer, isNull);
      print('PASS: should not create timer when reduceMotion is true');
    });

    test('should advance to next page when currentPage < 2', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      await Future.delayed(const Duration(seconds: 6));
      expect(carouselTimer.currentPage, equals(1));
      expect(carouselTimer.actions, contains('nextPage'));
      print('PASS: should advance to next page when currentPage < 2');
    });

    test('should loop back to page 0 when currentPage >= 2', () async {
      carouselTimer.setCurrentPage(2);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      await Future.delayed(const Duration(seconds: 6));
      expect(carouselTimer.currentPage, equals(0));
      expect(carouselTimer.actions, contains('animateToPage:0'));
      print('PASS: should loop back to page 0 when currentPage >= 2');
    });

    test('should handle resetTimer correctly', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      carouselTimer.resetTimer();
      expect(carouselTimer.timer, isNotNull);
      expect(carouselTimer.timer!.isActive, isTrue);
      print('PASS: should handle resetTimer correctly');
    });

    test('should handle dispose correctly', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      expect(carouselTimer.timer!.isActive, isTrue);
      carouselTimer.dispose();
      expect(carouselTimer.timer, isNull);
      print('PASS: should handle dispose correctly');
    });
  });
}