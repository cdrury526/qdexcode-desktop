import 'dart:convert';
import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

/// Keys used for window state persistence in shared_preferences.
abstract final class WindowStateKeys {
  static const prefix = 'qdex_window_';
  static const geometry = '${prefix}geometry';
  static const panelWidths = '${prefix}panel_widths';
  static const activeTab = '${prefix}active_tab';
  static const selectedProjectId = '${prefix}selected_project_id';
}

/// Immutable snapshot of window geometry (position + size).
class WindowGeometry {
  const WindowGeometry({
    required this.x,
    required this.y,
    required this.width,
    required this.height,
  });

  final double x;
  final double y;
  final double width;
  final double height;

  /// Default geometry for a new installation.
  static const defaultValue = WindowGeometry(
    x: 100,
    y: 100,
    width: 1280,
    height: 800,
  );

  Offset get position => Offset(x, y);
  Size get size => Size(width, height);

  Map<String, dynamic> toJson() => {
        'x': x,
        'y': y,
        'width': width,
        'height': height,
      };

  factory WindowGeometry.fromJson(Map<String, dynamic> json) {
    return WindowGeometry(
      x: (json['x'] as num).toDouble(),
      y: (json['y'] as num).toDouble(),
      width: (json['width'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WindowGeometry &&
          x == other.x &&
          y == other.y &&
          width == other.width &&
          height == other.height;

  @override
  int get hashCode => Object.hash(x, y, width, height);
}

/// Panel width proportions (flex values for left/center/right).
class PanelWidths {
  const PanelWidths({
    required this.leftFlex,
    required this.centerFlex,
    required this.rightFlex,
  });

  final double leftFlex;
  final double centerFlex;
  final double rightFlex;

  /// Default 20/60/20 split.
  static const defaultValue = PanelWidths(
    leftFlex: 2,
    centerFlex: 6,
    rightFlex: 2,
  );

  Map<String, dynamic> toJson() => {
        'leftFlex': leftFlex,
        'centerFlex': centerFlex,
        'rightFlex': rightFlex,
      };

  factory PanelWidths.fromJson(Map<String, dynamic> json) {
    return PanelWidths(
      leftFlex: (json['leftFlex'] as num).toDouble(),
      centerFlex: (json['centerFlex'] as num).toDouble(),
      rightFlex: (json['rightFlex'] as num).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PanelWidths &&
          leftFlex == other.leftFlex &&
          centerFlex == other.centerFlex &&
          rightFlex == other.rightFlex;

  @override
  int get hashCode => Object.hash(leftFlex, centerFlex, rightFlex);
}

/// Service that reads and writes window state to shared_preferences.
///
/// All persistence goes through this class so the providers do not need
/// to know about serialization details.
class WindowStateService {
  const WindowStateService();

  // -- Window Geometry --

  Future<WindowGeometry> loadGeometry() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(WindowStateKeys.geometry);
    if (raw == null) return WindowGeometry.defaultValue;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return WindowGeometry.fromJson(json);
    } catch (_) {
      return WindowGeometry.defaultValue;
    }
  }

  Future<void> saveGeometry(WindowGeometry geometry) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      WindowStateKeys.geometry,
      jsonEncode(geometry.toJson()),
    );
  }

  // -- Panel Widths --

  Future<PanelWidths> loadPanelWidths() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(WindowStateKeys.panelWidths);
    if (raw == null) return PanelWidths.defaultValue;
    try {
      final json = jsonDecode(raw) as Map<String, dynamic>;
      return PanelWidths.fromJson(json);
    } catch (_) {
      return PanelWidths.defaultValue;
    }
  }

  Future<void> savePanelWidths(PanelWidths widths) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      WindowStateKeys.panelWidths,
      jsonEncode(widths.toJson()),
    );
  }

  // -- Active Tab --

  Future<String?> loadActiveTab() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(WindowStateKeys.activeTab);
  }

  Future<void> saveActiveTab(String tabId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(WindowStateKeys.activeTab, tabId);
  }

  // -- Selected Project ID --

  Future<String?> loadSelectedProjectId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(WindowStateKeys.selectedProjectId);
  }

  Future<void> saveSelectedProjectId(String? projectId) async {
    final prefs = await SharedPreferences.getInstance();
    if (projectId == null) {
      await prefs.remove(WindowStateKeys.selectedProjectId);
    } else {
      await prefs.setString(WindowStateKeys.selectedProjectId, projectId);
    }
  }
}
