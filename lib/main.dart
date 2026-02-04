import 'package:flutter/material.dart';
import 'package:window_manager/window_manager.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'app.dart';
import 'services/task_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await windowManager.ensureInitialized();
  await windowManager.setPreventClose(true);

  // Restore last window size or use minimal default
  final savedSize = await TaskService.instance.getWindowSize();
  const minimalSize = Size(400, 800);
  final initialSize = savedSize ?? minimalSize;

  WindowOptions windowOptions = WindowOptions(
    size: initialSize,
    minimumSize: minimalSize,
    center: savedSize == null, // Only center if it's the first run
    backgroundColor: Colors.transparent,
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.hidden,
  );
  windowManager.waitUntilReadyToShow(windowOptions, () async {
    await windowManager.setMinimumSize(minimalSize);
    await windowManager.show();
    await windowManager.focus();
  });

  runApp(const TickTockApp());
}
