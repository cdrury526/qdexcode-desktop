/// Indexing progress widget for the dashboard.
///
/// Shows the last indexed timestamp and, when active, a live progress bar.
/// For now shows static state; will wire to pg-bridge WebSocket in Phase 4.
library;

import 'package:flutter/material.dart';

import 'package:qdexcode_desktop/core/models/project.dart';

/// Displays indexing status and last-indexed timestamp.
///
/// When the project is actively indexing, shows a progress indicator.
/// Otherwise shows the last indexed timestamp.
class IndexingProgress extends StatelessWidget {
  const IndexingProgress({
    super.key,
    required this.indexStatus,
    this.lastIndexedAt,
  });

  final IndexStatus indexStatus;
  final DateTime? lastIndexedAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: cs.outline),
      ),
      child: Row(
        children: [
          _statusIcon(cs),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _statusLabel,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: cs.onSurface,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                if (_isActive)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(2),
                    child: const SizedBox(
                      height: 4,
                      child: LinearProgressIndicator(),
                    ),
                  )
                else
                  Text(
                    _lastIndexedLabel,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.onTertiary,
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool get _isActive =>
      indexStatus == IndexStatus.indexing;

  String get _statusLabel {
    return switch (indexStatus) {
      IndexStatus.idle => 'Idle',
      IndexStatus.indexing => 'Indexing...',
      IndexStatus.indexFailed => 'Index Failed',
      IndexStatus.indexed => 'Indexed',
    };
  }

  String get _lastIndexedLabel {
    if (lastIndexedAt == null) return 'Never indexed';
    final diff = DateTime.now().difference(lastIndexedAt!);
    if (diff.inMinutes < 1) return 'Last indexed just now';
    if (diff.inMinutes < 60) return 'Last indexed ${diff.inMinutes}m ago';
    if (diff.inHours < 24) return 'Last indexed ${diff.inHours}h ago';
    return 'Last indexed ${diff.inDays}d ago';
  }

  Widget _statusIcon(ColorScheme cs) {
    if (_isActive) {
      return SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          color: cs.primary,
        ),
      );
    }

    final (icon, color) = switch (indexStatus) {
      IndexStatus.indexed => (Icons.check_circle_outline, const Color(0xFF22C55E)),
      IndexStatus.indexFailed => (Icons.error_outline, const Color(0xFFEF4444)),
      _ => (Icons.remove_circle_outline, cs.onTertiary),
    };

    return Icon(icon, size: 16, color: color);
  }
}
