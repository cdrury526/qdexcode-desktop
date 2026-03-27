import 'dart:async';

import 'package:flutter/material.dart';

/// Branded splash screen shown while the app initializes.
///
/// Displays the qdexcode wordmark on a dark background with a fade-in
/// animation. Stays visible for at least [minDisplayDuration] or until
/// [onInitComplete] fires, whichever is longer. Then performs a smooth
/// crossfade to [child] (the login page or main shell).
class SplashScreen extends StatefulWidget {
  const SplashScreen({
    super.key,
    required this.child,
    this.onInitComplete,
    this.minDisplayDuration = const Duration(milliseconds: 1800),
  });

  /// The widget to transition to after the splash completes.
  final Widget child;

  /// A future that resolves when app initialization is done (provider
  /// loading, token checks, API connectivity). If null the splash shows
  /// for exactly [minDisplayDuration].
  final Future<void>? onInitComplete;

  /// Minimum time the splash is visible, even if init finishes sooner.
  final Duration minDisplayDuration;

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _logoFadeIn;
  late final Animation<double> _subtitleFadeIn;

  bool _initDone = false;
  bool _minTimePassed = false;
  bool _transitioning = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Logo fades in over the first 800ms.
    _logoFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOut),
      ),
    );

    // Subtitle fades in slightly later (400ms - 1000ms).
    _subtitleFadeIn = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.35, 0.85, curve: Curves.easeOut),
      ),
    );

    _controller.forward();

    // Start the minimum display timer.
    Future<void>.delayed(widget.minDisplayDuration).then((_) {
      if (mounted) {
        _minTimePassed = true;
        _maybeTransition();
      }
    });

    // Wait for initialization to complete.
    if (widget.onInitComplete != null) {
      widget.onInitComplete!.then((_) {
        if (mounted) {
          _initDone = true;
          _maybeTransition();
        }
      });
    } else {
      _initDone = true;
    }
  }

  void _maybeTransition() {
    if (_initDone && _minTimePassed && !_transitioning) {
      _transitioning = true;
      if (mounted) setState(() {});
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 600),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      child: _transitioning
          ? KeyedSubtree(
              key: const ValueKey('app-content'),
              child: widget.child,
            )
          : KeyedSubtree(
              key: const ValueKey('splash'),
              child: _SplashContent(
                logoFadeIn: _logoFadeIn,
                subtitleFadeIn: _subtitleFadeIn,
                animation: _controller,
              ),
            ),
    );
  }
}

/// The visual content of the splash screen: dark background, centered
/// wordmark, and subtle tagline.
class _SplashContent extends StatelessWidget {
  const _SplashContent({
    required this.logoFadeIn,
    required this.subtitleFadeIn,
    required this.animation,
  });

  final Animation<double> logoFadeIn;
  final Animation<double> subtitleFadeIn;
  final Animation<double> animation;

  /// Splash background — always dark regardless of system theme.
  static const _background = Color(0xFF0A0A0A);
  static const _foreground = Color(0xFFFAFAFA);
  static const _mutedForeground = Color(0xFF737373);

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: _background,
      child: Center(
        child: AnimatedBuilder(
          animation: animation,
          builder: (context, child) {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo / wordmark
                Opacity(
                  opacity: logoFadeIn.value,
                  child: Transform.translate(
                    offset: Offset(0, 8 * (1 - logoFadeIn.value)),
                    child: const _Wordmark(),
                  ),
                ),
                const SizedBox(height: 16),
                // Tagline
                Opacity(
                  opacity: subtitleFadeIn.value,
                  child: const Text(
                    'Code Intelligence Platform',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: _mutedForeground,
                      decoration: TextDecoration.none,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Text-based wordmark: the "qdexcode" brand name in a clean monospace style.
///
/// This serves as placeholder until a proper logo asset is added.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return const Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Stylized bracket icon as a logo stand-in.
        Text(
          '</>',
          style: TextStyle(
            fontFamily: 'Menlo',
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Color(0xFF3B82F6), // info blue accent
            decoration: TextDecoration.none,
            height: 1.0,
          ),
        ),
        SizedBox(width: 12),
        Text(
          'qdexcode',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 36,
            fontWeight: FontWeight.w700,
            color: _SplashContent._foreground,
            decoration: TextDecoration.none,
            letterSpacing: -0.5,
            height: 1.0,
          ),
        ),
      ],
    );
  }
}
