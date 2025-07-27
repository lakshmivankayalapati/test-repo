import 'package:flutter/material.dart';

import '../../../../theme.dart';

enum Corner { topLeft, topRight, bottomLeft, bottomRight }

class CutCornerButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget child;
  final Set<Corner> cornersToClip;
  final double cutSize;
  final double height;
  final double? width;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Border? border;

  const CutCornerButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.cornersToClip = const {},
    this.cutSize = 16.0,
    this.height = 52.0,
    this.width,
    this.gradient,
    this.backgroundColor = AppTheme.buttonDark,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: ClipPath(
        clipper: _CutCornerClipper(corners: cornersToClip, cutSize: cutSize),
        child: Container(
          decoration: BoxDecoration(
            gradient: gradient,
            color: gradient == null ? backgroundColor : null,
            border: border,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onPressed,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}

class _CutCornerClipper extends CustomClipper<Path> {
  final Set<Corner> corners;
  final double cutSize;

  _CutCornerClipper({required this.corners, required this.cutSize});

  @override
  Path getClip(Size size) {
    final path = Path();
    if (corners.contains(Corner.topLeft)) {
      path.moveTo(cutSize, 0);
    } else {
      path.moveTo(0, 0);
    }
    if (corners.contains(Corner.topRight)) {
      path.lineTo(size.width - cutSize, 0);
      path.lineTo(size.width, cutSize);
    } else {
      path.lineTo(size.width, 0);
    }
    if (corners.contains(Corner.bottomRight)) {
      path.lineTo(size.width, size.height - cutSize);
      path.lineTo(size.width - cutSize, size.height);
    } else {
      path.lineTo(size.width, size.height);
    }
    if (corners.contains(Corner.bottomLeft)) {
      path.lineTo(cutSize, size.height);
      path.lineTo(0, size.height - cutSize);
    } else {
      path.lineTo(0, size.height);
    }
    if (corners.contains(Corner.topLeft)) {
      path.lineTo(0, cutSize);
    }
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
} 