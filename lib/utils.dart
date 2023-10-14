import 'package:flutter/material.dart';

enum EditorAction {
  none,
  lineDDA,
  lineBresenham,
  lineVu,
  ellipse,
  circle,
  hyperbola,
  parabola,
  Ermit,
  Bezier,
  bspline
}

class Point {
  int x;
  int y;
  int z = 0;
  int p = 1;

  Color color = Colors.black;

  Point(this.x, this.y, this.z, this.p, this.color);

  Point.vec2(this.x, this.y, this.color);

  Point.vec2b(this.x, this.y);

  Point.vec3(this.x, this.y, this.z, this.color);

  Offset getOffset() => Offset(x.toDouble(), y.toDouble());

  Color getColor() => color;
}

class GraphicalEditorAction {
  GraphicalEditorAction(this.action) {
    if (action == EditorAction.lineDDA ||
        action == EditorAction.lineBresenham ||
        action == EditorAction.lineVu) arguments = ['0', '0', '0', '0'];
  }

  EditorAction action;
  List<String> arguments = [];

  void addArgument(String arg) {
    arguments.add(arg);
  }

  void popArgument() {
    if (arguments.isNotEmpty)
      arguments = arguments.sublist(0, arguments.length - 1);
  }

  void clearArguments() {
    arguments.clear();
  }

  @override
  String toString() {
    if (action == EditorAction.none)
      return "отсутствует";
    else if (action == EditorAction.lineDDA)
      return "ЦДА";
    else if (action == EditorAction.lineBresenham)
      return "Алгоритм Брезенхейма";
    else if (action == EditorAction.lineVu)
      return "Алгоритм Ву";
    else if (action == EditorAction.ellipse)
      return "Элипс";
    else if (action == EditorAction.circle)
      return "Окружность";
    else if (action == EditorAction.hyperbola)
      return "Гипербола";
    else if (action == EditorAction.parabola)
      return "Парабола";
    else if (action == EditorAction.Ermit)
      return "Кривая Эрмита";
    else if (action == EditorAction.Bezier)
      return "Кривая Безье";
    else if (action == EditorAction.bspline) return "B-сплайн";

    return "Н/А";
  }
}
