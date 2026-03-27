/// Individual file tree node widget.
///
/// Renders a single row in the virtualized tree: expand chevron (dirs only),
/// file/folder icon colored by extension, name, and optional file size.
/// Compact height (30px) for dense information display.
library;

import 'package:flutter/material.dart';

import 'package:qdexcode_desktop/features/file_tree/file_tree_provider.dart';

/// A single row in the file tree.
///
/// [depth] controls left indentation (16px per level).
/// [isExpanded] shows the chevron rotation for directories.
/// [onTap] fires on single click (expand/collapse for dirs).
/// [onDoubleTap] fires on double-click (open file).
class FileTreeNode extends StatefulWidget {
  const FileTreeNode({
    required this.entry,
    required this.depth,
    required this.isExpanded,
    this.onTap,
    this.onDoubleTap,
    super.key,
  });

  final FileTreeEntry entry;
  final int depth;
  final bool isExpanded;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  @override
  State<FileTreeNode> createState() => _FileTreeNodeState();
}

class _FileTreeNodeState extends State<FileTreeNode> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final indent = 16.0 + widget.depth * 16.0;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: widget.onTap,
        onDoubleTap: widget.onDoubleTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 120),
          height: 30,
          padding: EdgeInsets.only(left: indent, right: 8),
          decoration: BoxDecoration(
            color: _hovered ? cs.secondary : Colors.transparent,
          ),
          child: Row(
            children: [
              // Expand/collapse chevron (directories only).
              if (widget.entry.isDirectory)
                AnimatedRotation(
                  turns: widget.isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: Icon(
                    Icons.chevron_right,
                    size: 14,
                    color: cs.onTertiary,
                  ),
                )
              else
                const SizedBox(width: 14),

              const SizedBox(width: 4),

              // File/folder icon.
              _FileIcon(
                name: widget.entry.name,
                isDirectory: widget.entry.isDirectory,
                isExpanded: widget.isExpanded,
              ),

              const SizedBox(width: 6),

              // File name.
              Expanded(
                child: Text(
                  widget.entry.name,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    color: cs.onSurface,
                    fontWeight: widget.entry.isDirectory
                        ? FontWeight.w500
                        : FontWeight.w400,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ),

              // File size (files only, when not too small).
              if (!widget.entry.isDirectory && widget.entry.size != null)
                Padding(
                  padding: const EdgeInsets.only(left: 6),
                  child: Text(
                    _formatSize(widget.entry.size!),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10,
                      color: cs.onTertiary.withValues(alpha: 0.6),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// File icon with extension-based coloring
// ---------------------------------------------------------------------------

class _FileIcon extends StatelessWidget {
  const _FileIcon({
    required this.name,
    required this.isDirectory,
    required this.isExpanded,
  });

  final String name;
  final bool isDirectory;
  final bool isExpanded;

  @override
  Widget build(BuildContext context) {
    if (isDirectory) {
      return Icon(
        isExpanded ? Icons.folder_open_rounded : Icons.folder_rounded,
        size: 16,
        color: const Color(0xFFE8A838), // warm amber for folders
      );
    }

    final (IconData icon, Color color) = _iconForFile(name);
    return Icon(icon, size: 16, color: color);
  }

  static (IconData, Color) _iconForFile(String name) {
    final ext = name.contains('.') ? name.split('.').last.toLowerCase() : '';

    return switch (ext) {
      // Dart / Flutter
      'dart' => (Icons.code_rounded, const Color(0xFF0175C2)),

      // JavaScript / TypeScript
      'js' || 'mjs' || 'cjs' => (Icons.javascript_rounded, const Color(0xFFF7DF1E)),
      'ts' || 'tsx' => (Icons.code_rounded, const Color(0xFF3178C6)),
      'jsx' => (Icons.code_rounded, const Color(0xFF61DAFB)),

      // Web
      'html' || 'htm' => (Icons.language_rounded, const Color(0xFFE34F26)),
      'css' || 'scss' || 'sass' => (Icons.palette_rounded, const Color(0xFF1572B6)),

      // Data / Config
      'json' => (Icons.data_object_rounded, const Color(0xFFA3A3A3)),
      'yaml' || 'yml' => (Icons.settings_rounded, const Color(0xFFCB171E)),
      'toml' => (Icons.settings_rounded, const Color(0xFF9C4121)),
      'xml' => (Icons.code_rounded, const Color(0xFFA3A3A3)),

      // Documentation
      'md' || 'mdx' => (Icons.description_rounded, const Color(0xFF5B9BD5)),
      'txt' => (Icons.text_snippet_rounded, const Color(0xFFA3A3A3)),
      'pdf' => (Icons.picture_as_pdf_rounded, const Color(0xFFFF0000)),

      // Go
      'go' => (Icons.code_rounded, const Color(0xFF00ADD8)),
      'mod' || 'sum' => (Icons.settings_rounded, const Color(0xFF00ADD8)),

      // Python
      'py' => (Icons.code_rounded, const Color(0xFF3776AB)),

      // Rust
      'rs' => (Icons.code_rounded, const Color(0xFFDEA584)),

      // Shell
      'sh' || 'bash' || 'zsh' => (Icons.terminal_rounded, const Color(0xFF4EAA25)),

      // Docker
      'dockerfile' => (Icons.layers_rounded, const Color(0xFF2496ED)),

      // Images
      'png' || 'jpg' || 'jpeg' || 'gif' || 'svg' || 'webp' || 'ico' =>
        (Icons.image_rounded, const Color(0xFF8BC34A)),

      // Lock files
      'lock' => (Icons.lock_rounded, const Color(0xFF737373)),

      // SQL
      'sql' => (Icons.storage_rounded, const Color(0xFFE38C00)),

      // Env
      'env' => (Icons.vpn_key_rounded, const Color(0xFFEAB308)),

      // Log
      'log' => (Icons.receipt_long_rounded, const Color(0xFF737373)),

      // Default
      _ => (Icons.insert_drive_file_rounded, const Color(0xFF737373)),
    };
  }
}

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------

/// Formats a byte count into a human-readable string.
String _formatSize(int bytes) {
  if (bytes < 1024) return '${bytes}B';
  if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)}K';
  if (bytes < 1024 * 1024 * 1024) {
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}M';
  }
  return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)}G';
}
