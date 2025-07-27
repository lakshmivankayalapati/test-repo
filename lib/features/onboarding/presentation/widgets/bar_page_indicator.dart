import 'package:flutter/material.dart';

class BarPageIndicator extends StatelessWidget {
  final int currentIndex;
  final int pageCount;

  const BarPageIndicator({
    super.key,
    required this.currentIndex,
    required this.pageCount,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const figmaScreenWidth = 375.0;

    return Semantics(
      label: 'Page ${currentIndex + 1} of $pageCount',
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(pageCount, (index) {
          final bool isActive = index == currentIndex;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(horizontal: 1.0),
            height: 5.0 * (screenWidth / figmaScreenWidth),
            width: (isActive ? 32.0 : 8.0) * (screenWidth / figmaScreenWidth),
            decoration: BoxDecoration(
              color: isActive ? Colors.black : const Color(0xFF838383),
            ),
          );
        }),
      ),
    );
  }
} 