import "package:flutter/material.dart";
import 'package:graphical_editor/utils/tools.dart';
import 'package:graphical_editor/utils/utils.dart';

class ToolStatusBar extends StatelessWidget {
  const ToolStatusBar(this.toolInfo, {super.key});
  final ToolInfo? toolInfo;

  Widget _createKeyValueField(String key, String value,
      {double startMargin = 0.0, double endMargin = 0.0}) {
    return Row(children: [
      SizedBox(width: startMargin),
      Text(key, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      Expanded(child: SizedBox()),
      Text(value),
      SizedBox(width: endMargin)
    ]);
  }

  @override
  Widget build(BuildContext context) {
    String toolName = toolInfo == null ? "Отсутствует" : toolInfo!.toolName;

    return Container(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(color: Colors.transparent),
        child: Column(
          children: [
            Divider(height: 1.8, color: Colors.black, thickness: 1.8),
            _createKeyValueField("Инструмент:", toolName,
                startMargin: 12.0, endMargin: 10.0),
            Divider(height: 1.8, color: Colors.black, thickness: 1.8),
          ],
        ),
      ),
    );
  }
}
