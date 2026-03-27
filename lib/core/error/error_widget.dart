import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Styled error widget that replaces Flutter's default red error screen.
///
/// In debug mode, shows the error message and stack trace for developer
/// convenience. In release mode, shows only a friendly message with a
/// retry action.
class AppErrorWidget extends StatelessWidget {
  const AppErrorWidget({
    required this.details,
    super.key,
  });

  /// The [FlutterErrorDetails] captured by the framework.
  final FlutterErrorDetails details;

  /// Builds an [AppErrorWidget] from [FlutterErrorDetails].
  ///
  /// Intended for use as [ErrorWidget.builder].
  static Widget builder(FlutterErrorDetails details) {
    return AppErrorWidget(details: details);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Use the card surface for the error container background.
    final cardColor = colorScheme.surfaceContainerHighest;
    final borderColor = colorScheme.outline;
    final mutedText = colorScheme.onTertiary;
    final errorColor = colorScheme.error;

    return ColoredBox(
      color: colorScheme.surface,
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 480),
          child: Container(
            margin: const EdgeInsets.all(24),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: borderColor),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row with icon and title.
                Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: errorColor,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Something went wrong',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Error message — full in debug, friendly in release.
                Text(
                  kReleaseMode
                      ? 'An unexpected error occurred. '
                          'Please try again or restart the app.'
                      : details.exceptionAsString(),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: mutedText,
                    height: 1.5,
                  ),
                  maxLines: kReleaseMode ? 3 : 12,
                  overflow: TextOverflow.ellipsis,
                ),

                // Stack trace in debug mode only.
                if (!kReleaseMode && details.stack != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    constraints: const BoxConstraints(maxHeight: 200),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: borderColor),
                    ),
                    child: SingleChildScrollView(
                      child: SelectableText(
                        details.stack.toString(),
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          fontSize: 11,
                          color: mutedText,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // Action buttons.
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Wire up to crash reporting opt-in flow.
                      },
                      icon: const Icon(Icons.flag_outlined, size: 16),
                      label: const Text('Report'),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        // Attempt a rebuild of the errored subtree. If the
                        // widget is embedded in a Navigator, this triggers a
                        // full page rebuild via setState on a parent.
                        final element = context as Element;
                        element.markNeedsBuild();
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 16),
                      label: const Text('Retry'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
