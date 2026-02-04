import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'app.dart';
import 'services/task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.setPreventClose(true);

  // Restore last window size
  final savedSize = await TaskService.instance.getWindowSize();
  final initialSize = savedSize ?? const Size(1000, 800);

  WindowOptions windowOptions = WindowOptions(
    size: initialSize,
    center: savedSize == null, // Only center if it's the first run
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const TickTockApp());
}
