import 'package:flutter/widgets.dart';

class AddTaskIntent extends Intent {
  const AddTaskIntent();
}

class FocusSearchIntent extends Intent {
  const FocusSearchIntent();
}

class ToggleTrackingIntent extends Intent {
  const ToggleTrackingIntent();
}

class ClearSearchIntent extends Intent {
  const ClearSearchIntent();
}

class ShowHelpIntent extends Intent {
  const ShowHelpIntent();
}

class JumpToDateIntent extends Intent {
  const JumpToDateIntent();
}

class GoToTodayIntent extends Intent {
  const GoToTodayIntent();
}

class TrackActivityTaskIntent extends Intent {
  final int index;
  const TrackActivityTaskIntent(this.index);
}

class EditLibraryTaskIntent extends Intent {
  final String char;
  const EditLibraryTaskIntent(this.char);
}
