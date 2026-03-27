import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:qdexcode_desktop/app.dart';
import 'package:qdexcode_desktop/core/error/error_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initErrorHandler();

  runApp(
    const ProviderScope(
      child: QdexcodeApp(),
    ),
  );
}
