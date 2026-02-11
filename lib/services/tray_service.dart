import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';

class TrayService with TrayListener {
  static final TrayService instance = TrayService._();
  TrayService._();

  Future<void> init() async {
    trayManager.addListener(this);
    await _setupTray();
  }

  Future<void> _setupTray() async {
    // macOS tray icon (using the one from assets)
    String iconPath = Platform.isWindows ? 'assets/app_icon.ico' : 'assets/tray_icon.png';
    
    await trayManager.setIcon(iconPath);
    
    List<MenuItem> items = [
      MenuItem(
        key: 'show_window',
        label: 'Show TickTock',
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit_app',
        label: 'Quit TickTock',
      ),
    ];
    await trayManager.setContextMenu(Menu(items: items));
  }

  @override
  void onTrayIconMouseDown() async {
    await _toggleWindow();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) async {
    if (menuItem.key == 'show_window') {
      await windowManager.show();
      await windowManager.focus();
    } else if (menuItem.key == 'exit_app') {
      exit(0);
    }
  }

  Future<void> _toggleWindow() async {
    bool isVisible = await windowManager.isVisible();
    if (isVisible) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  }
}
