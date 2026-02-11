import 'dart:io';
import 'package:flutter/material.dart';
import 'package:tray_manager/tray_manager.dart';
import 'package:window_manager/window_manager.dart';
import 'task_service.dart';

class TrayService with TrayListener {
  static final TrayService instance = TrayService._();
  TrayService._();

  bool _showCurrentTask = false;

  Future<void> init() async {
    trayManager.addListener(this);
    final setting = await TaskService.instance.getSetting('show_tray_text');
    _showCurrentTask = setting == 'true';
    await _setupTray();
    await updateTrayText();
  }

  Future<void> _setupTray() async {
    // macOS tray icon (using the one from assets)
    String iconPath = Platform.isWindows ? 'assets/app_icon.ico' : 'assets/tray_icon_Template.png';
    
    await trayManager.setIcon(iconPath, isTemplate: true);
    
    List<MenuItem> items = [
      MenuItem(
        key: 'show_window',
        label: 'Show TickTock',
      ),
      MenuItem.checkbox(
        key: 'toggle_show_task',
        label: 'Show Current Task',
        checked: _showCurrentTask,
      ),
      MenuItem.separator(),
      MenuItem(
        key: 'exit_app',
        label: 'Quit TickTock',
      ),
    ];
    await trayManager.setContextMenu(Menu(items: items));
  }

  Future<void> updateTrayText([String? title]) async {
    if (!_showCurrentTask) {
      await trayManager.setTitle('');
      return;
    }

    if (title != null) {
      await trayManager.setTitle(title);
    } else {
      final state = await TaskService.instance.getTrackingState();
      if (state != null) {
        await trayManager.setTitle(state['title']);
      } else {
        await trayManager.setTitle('');
      }
    }
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
    } else if (menuItem.key == 'toggle_show_task') {
      _showCurrentTask = !(_showCurrentTask);
      await TaskService.instance.saveSetting('show_tray_text', _showCurrentTask.toString());
      await _setupTray();
      await updateTrayText();
    } else if (menuItem.key == 'exit_app') {
      exit(0);
    }
  }

  Future<void> _toggleWindow() async {
    bool isFocused = await windowManager.isFocused();
    if (isFocused) {
      await windowManager.hide();
    } else {
      await windowManager.show();
      await windowManager.focus();
    }
  }
}
