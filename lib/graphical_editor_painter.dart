import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:graphical_editor/utils/tool_history.dart';
import 'package:graphical_editor/utils/tools.dart';
import 'package:graphical_editor/utils/utils.dart';

class GraphicalEditorPainter extends CustomPainter {
  GraphicalEditorPainter(this.points);
  List<Point> points;

  void _drawPointsWithColor(Canvas canvas, List<Point> points) {
    for (int i = 0; i < points.length; i++) {
      Offset point = points[i].getOffset();
      Paint brush = Paint()
        ..color = points[i].getColor()
        ..strokeWidth = points[i].boldness.toDouble();

      canvas.drawPoints(PointMode.points, [point], brush);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _drawPointsWithColor(canvas, points);
  }

  @override
  bool shouldRepaint(CustomPainter old) => true;
}
