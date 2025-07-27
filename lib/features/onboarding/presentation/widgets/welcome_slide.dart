import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class WelcomeSlide extends StatefulWidget {
  final String image;
  final String title;
  final String description;
  final bool isActive;

  const WelcomeSlide({
    super.key,
    required this.image,
    required this.title,
    required this.description,
    required this.isActive,
  });

  @override
  State<WelcomeSlide> createState() => _WelcomeSlideState();
}

class _WelcomeSlideState extends State<WelcomeSlide>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Offset> _titleAnimation;
  late final Animation<Offset> _descriptionAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _titleAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _descriptionAnimation =
        Tween<Offset>(begin: const Offset(1.0, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    if (widget.isActive) {
      _animationController.forward();
    }
  }

  @override
  void didUpdateWidget(covariant WelcomeSlide oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isActive && !oldWidget.isActive) {
      _animationController.forward(from: 0.0);
    } else if (!widget.isActive && oldWidget.isActive) {
      _animationController.reset();
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    const figmaScreenHeight = 812.0;
    const figmaScreenWidth = 375.0;

    final imageHeight = screenHeight * 0.6;
    final imageWidth = screenWidth * 0.9;
    final maxImageHeight = screenHeight * 0.6;
    final maxImageWidth = screenWidth * 0.9;

    return Semantics(
      label: '${widget.title}. ${widget.description}',
      child: Container(
        color: Colors.white,
        child: Column(
          children: [
            SizedBox(
                height: (MediaQuery.of(context).padding.top + 20) *
                    (screenHeight / figmaScreenHeight)),
            Expanded(
              flex: 3,
              child: Align(
                alignment: Alignment.centerRight,
                child: Container(
                  height: maxImageHeight > imageHeight
                      ? maxImageHeight
                      : imageHeight,
                  width: imageWidth > maxImageWidth ? maxImageWidth : imageWidth,
                  constraints: BoxConstraints(
                    minHeight: 200.0,
                    minWidth: 200.0,
                    maxHeight: maxImageHeight,
                    maxWidth: maxImageWidth,
                  ),
                  child: Image.asset(
                    widget.image,
                    fit: BoxFit.contain,
                    alignment: Alignment.centerRight,
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: 20 * (screenWidth / figmaScreenWidth)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(height: 32 * (screenHeight / figmaScreenHeight)),
                  ClipRect(
                    child: SlideTransition(
                      position: _titleAnimation,
                      child: Text(
                        widget.title,
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              fontSize: 32 *
                                  (MediaQuery.of(context).size.width / 375),
                            ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12 * (screenHeight / figmaScreenHeight)),
                  ClipRect(
                    child: SlideTransition(
                      position: _descriptionAnimation,
                      child: Text(
                        widget.description,
                        style: GoogleFonts.nunito(
                          fontWeight: FontWeight.w500,
                          fontSize:
                              16 * (MediaQuery.of(context).size.width / 375),
                          height: 1.5,
                          letterSpacing: 0.08,
                          color: const Color(0xFF1C1C1C),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 32 * (screenHeight / figmaScreenHeight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
