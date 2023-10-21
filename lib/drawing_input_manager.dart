import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:graphical_editor/graphical_editor_painter.dart';
import 'package:graphical_editor/utils/arguments.dart';
import 'package:graphical_editor/utils/tool_history.dart';
import 'package:graphical_editor/utils/tools.dart';
import 'package:graphical_editor/utils/utils.dart';

class DrawingInputManager extends StatefulWidget {
  DrawingInputManager(this.history, this.currentTool, {super.key});

  ToolHistory history;
  ToolInfo currentTool;

  @override
  State<DrawingInputManager> createState() => _DrawingInputManagerState();
}

class _DrawingInputManagerState extends State<DrawingInputManager> {
  List<Point> _pushPoints() {
    List<Point> pointsToDraw = [];

    for (var toolInfo in widget.history.getInfo()) {
      toolInfo.tool.paint(pointsToDraw, toolInfo.inputMethod.arguments);
      toolInfo.tool.supportPaint(pointsToDraw, toolInfo.inputMethod.arguments);
    }

    widget.currentTool.tool
        .paint(pointsToDraw, widget.currentTool.inputMethod.arguments);
    widget.currentTool.tool
        .supportPaint(pointsToDraw, widget.currentTool.inputMethod.arguments);
    
    return pointsToDraw;
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
          margin: EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(color: Colors.white, boxShadow: [
            const BoxShadow(color: Colors.grey, spreadRadius: 1, blurRadius: 5),
          ]),
          child: GestureDetector(
            onPanStart: (var details) {
              setState(() {
                widget.currentTool.inputMethod.onInputStart(details);
              });
            },
            onPanUpdate: (var details) {
              setState(() {
                widget.currentTool.inputMethod.onInputUpdate(details);
              });
            },
            onPanEnd: (var details) {
              setState(() {
                widget.currentTool.inputMethod.onInputEnd(details);
                if (widget.currentTool.inputMethod.isReady) {
                  widget.history.add(widget.currentTool);
                  widget.currentTool.inputMethod =
                      widget.currentTool.inputMethod.reset();
                }
              });
            },
            child: ClipRect(
              child: CustomPaint(
                  foregroundPainter: GraphicalEditorPainter(_pushPoints()),
                  child: Container(color: Colors.white)),
            ),
          )),
    );
    ;
  }
}
