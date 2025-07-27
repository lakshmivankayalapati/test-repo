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

    test('startTimer should create a periodic timer when reduceMotion is false', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      expect(carouselTimer.timer, isNotNull);
      expect(carouselTimer.timer!.isActive, isTrue);
      await Future.delayed(const Duration(seconds: 6));
      expect(carouselTimer.timer!.isActive, isTrue);
      print('PASS: startTimer should create a periodic timer when reduceMotion is false');
    });

    test('startTimer should advance to next page when currentPage < 2', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      await Future.delayed(const Duration(seconds: 6));
      expect(carouselTimer.currentPage, equals(1));
      expect(carouselTimer.actions, contains('nextPage'));
      expect(carouselTimer.timer!.isActive, isTrue);
      print('PASS: startTimer should advance to next page when currentPage < 2');
    });

    test('startTimer should loop back to page 0 when currentPage >= 2', () async {
      carouselTimer.setCurrentPage(2);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      await Future.delayed(const Duration(seconds: 6));
      expect(carouselTimer.currentPage, equals(0));
      expect(carouselTimer.actions, contains('animateToPage:0'));
      expect(carouselTimer.timer!.isActive, isTrue);
      print('PASS: startTimer should loop back to page 0 when currentPage >= 2');
    });

    test('resetTimer should cancel existing timer and restart if reduceMotion is false', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      carouselTimer.resetTimer();
      expect(carouselTimer.timer, isNotNull);
      expect(carouselTimer.timer!.isActive, isTrue);
      print('PASS: resetTimer should cancel existing timer and restart if reduceMotion is false');
    });

    test('resetTimer should cancel timer and not restart if reduceMotion is true', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(true);
      carouselTimer.startTimer();
      carouselTimer.resetTimer();
      expect(carouselTimer.timer, isNull);
      print('PASS: resetTimer should cancel timer and not restart if reduceMotion is true');
    });

    test('dispose should cancel timer', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      expect(carouselTimer.timer!.isActive, isTrue);
      carouselTimer.dispose();
      expect(carouselTimer.timer, isNull);
      print('PASS: dispose should cancel timer');
    });

    test('multiple timer ticks should work correctly', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      await Future.delayed(const Duration(seconds: 16));
      expect(carouselTimer.currentPage, equals(0));
      expect(carouselTimer.timer!.isActive, isTrue);
      expect(carouselTimer.actions.where((a) => a == 'nextPage').length, equals(2));
      expect(carouselTimer.actions.where((a) => a == 'animateToPage:0').length, equals(1));
      print('PASS: multiple timer ticks should work correctly');
    });

    test('timer should not be created when reduceMotion is true', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(true);
      carouselTimer.startTimer();
      expect(carouselTimer.timer, isNull);
      print('PASS: timer should not be created when reduceMotion is true');
    });

    test('timer should be created when reduceMotion is false', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      expect(carouselTimer.timer, isNotNull);
      expect(carouselTimer.timer!.isActive, isTrue);
      print('PASS: timer should be created when reduceMotion is false');
    });

    test('should handle page advancement through all pages', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      await Future.delayed(const Duration(seconds: 6));
      expect(carouselTimer.currentPage, equals(1));
      await Future.delayed(const Duration(seconds: 5));
      expect(carouselTimer.currentPage, equals(2));
      await Future.delayed(const Duration(seconds: 5));
      expect(carouselTimer.currentPage, equals(0));
      expect(carouselTimer.actions, equals(['nextPage', 'nextPage', 'animateToPage:0']));
      print('PASS: should handle page advancement through all pages');
    });

    test('should handle timer cancellation and restart', () async {
      carouselTimer.setCurrentPage(0);
      carouselTimer.setReduceMotion(false);
      carouselTimer.startTimer();
      carouselTimer.resetTimer();
      await Future.delayed(const Duration(seconds: 6));
      expect(carouselTimer.currentPage, equals(1));
      expect(carouselTimer.actions, contains('nextPage'));
      print('PASS: should handle timer cancellation and restart');
    });
  });
}