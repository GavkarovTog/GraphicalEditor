import 'package:graphical_editor/utils/tools.dart';

class ToolHistory {
  int _currentSnapshot = 0;
  List<ToolInfo> history = [];

  List<ToolInfo> getInfo() {
    return history.sublist(0, _currentSnapshot);
  }

  void add(ToolInfo toolInfo) {
    history = history.sublist(0, _currentSnapshot);
    history.add(ToolInfo(toolInfo.toolName, toolInfo.tool, toolInfo.inputMethod));
    _currentSnapshot ++;
  }

  void back() {
    if (_currentSnapshot > 0) {
      _currentSnapshot --;
    }
  }

  void forward() {
    if (_currentSnapshot < history.length) {
      _currentSnapshot ++;
    }
  }

  void clip() {
    history = history.sublist(0, _currentSnapshot);
  }

  void reset() {
    _currentSnapshot = 0;
    history = [];
  }
}