/// Animated connection status badge for the left panel footer.
///
/// Shows a colored dot with optional label:
/// - Green (pulse) = connected
/// - Yellow (pulse animation) = connecting / reconnecting
/// - Red = disconnected / error
///
/// Compact (28px height), shows connection text on hover.
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/core/realtime/realtime_events.dart';
import 'package:qdexcode_desktop/core/realtime/realtime_provider.dart';

/// Small connection status indicator for the left panel footer.
///
/// Watches [realtimeConnectionStatusProvider] and animates transitions
/// between connection states with a subtle pulse on reconnecting.
class ConnectionBadge extends ConsumerStatefulWidget {
  const ConnectionBadge({super.key});

  @override
  ConsumerState<ConnectionBadge> createState() => _ConnectionBadgeState();
}

class _ConnectionBadgeState extends ConsumerState<ConnectionBadge>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _pulseAnimation = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _syncAnimation(ConnectionStatus status) {
    final shouldPulse =
        status == ConnectionStatus.connecting ||
        status == ConnectionStatus.reconnecting;

    if (shouldPulse && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!shouldPulse && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.value = 1.0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final status = ref.watch(realtimeConnectionStatusProvider);
    _syncAnimation(status);

    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final (Color dotColor, String label, String tooltip) = switch (status) {
      ConnectionStatus.connected => (
        const Color(0xFF22C55E), // green-500
        'Connected',
        'Realtime: connected to pg-bridge',
      ),
      ConnectionStatus.connecting => (
        const Color(0xFFEAB308), // yellow-500
        'Connecting...',
        'Establishing WebSocket connection',
      ),
      ConnectionStatus.reconnecting => (
        const Color(0xFFEAB308), // yellow-500
        'Reconnecting...',
        'Connection lost, reconnecting with backoff',
      ),
      ConnectionStatus.disconnected => (
        cs.onTertiary.withValues(alpha: 0.4),
        'Disconnected',
        'Not connected to realtime server',
      ),
      ConnectionStatus.error => (
        const Color(0xFFEF4444), // red-500
        'Error',
        'Connection failed after max retries',
      ),
    };

    return Tooltip(
      message: tooltip,
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: SizedBox(
          height: 28,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated dot
              _AnimatedDot(
                color: dotColor,
                animation: _pulseAnimation,
                glowing: status == ConnectionStatus.connected,
              ),

              // Label: always visible when hovered, otherwise compact
              AnimatedSize(
                duration: const Duration(milliseconds: 200),
                curve: Curves.easeInOut,
                child: _hovered
                    ? Padding(
                        padding: const EdgeInsets.only(left: 6),
                        child: Text(
                          label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: cs.onTertiary,
                            fontSize: 10,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A 6x6 dot that pulses opacity based on an animation value.
class _AnimatedDot extends AnimatedWidget {
  const _AnimatedDot({
    required this.color,
    required Animation<double> animation,
    this.glowing = false,
  }) : super(listenable: animation);

  final Color color;
  final bool glowing;

  @override
  Widget build(BuildContext context) {
    final animation = listenable as Animation<double>;
    return Container(
      width: 6,
      height: 6,
      decoration: BoxDecoration(
        color: color.withValues(alpha: animation.value),
        shape: BoxShape.circle,
        boxShadow: glowing
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.3),
                  blurRadius: 4,
                  spreadRadius: 1,
                ),
              ]
            : null,
      ),
    );
  }
}
