import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';

enum EditorAction {
  none,
  lineDDA,
  lineBresenham,
  lineVu,
  ellipse,
  circle,
  hyperbola,
  parabola
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
    else if (action == EditorAction.parabola) return "Парабола";

    return "Н/А";
  }
}

class GraphicalEditorPainter extends CustomPainter {
  GraphicalEditorPainter(this.toDraw, this.toPlan);

  List<GraphicalEditorAction> toDraw;
  GraphicalEditorAction toPlan;

  List<Point> getLineDDAPoints(Offset start, Offset end) {
    List<Point> points = [];

    if (start == end) {
      return [Point.vec2b(start.dx.toInt(), start.dy.toInt())];
    }

    double length = max((end.dx - start.dx).abs(), (end.dy - start.dy).abs());

    double dx = (end.dx - start.dx) / length;
    double dy = (end.dy - start.dy) / length;

    double x = start.dx.round().toDouble();
    double y = start.dy.round().toDouble();

    points.add(Point.vec2b(x.toInt(), y.toInt()));

    int i = 0;
    while (i < length) {
      x = x + dx;
      y = y + dy;

      points.add(Point.vec2b(x.toInt(), y.toInt()));
      i++;
    }

    return points;
  }

  List<Point> getLineBresenhamPoints(Offset start, Offset end) {
    int x = start.dx.toInt();
    int y = start.dy.toInt();

    int dx = end.dx.toInt() - x;
    int dy = end.dy.toInt() - y;

    List<Point> points = [Point.vec2b(x, y)];
    bool xIsLeading = dy.abs() < dx.abs();

    int octant = 1;
    if (dx < 0 && dy > 0) {
      octant = 2;
    } else if (dx < 0 && dy < 0) {
      octant = 3;
    } else if (dx > 0 && dy < 0) {
      octant = 4;
    }

    int error = xIsLeading ? 2 * dy - dx : 2 * dx - dy;

    int i = 1;
    while (xIsLeading && i < dx.abs() || !xIsLeading && i < dy.abs()) {
      if (xIsLeading) {
        if (error >= 0) {
          if (octant == 1) {
            y++;
            error -= 2 * dx;
          } else if (octant == 2) {
            y++;
            error -= 2 * dx.abs();
          } else if (octant == 3) {
            y--;
            error -= 2 * dx.abs();
          } else {
            y--;
            error -= 2 * dx;
          }
        }

        if (octant == 1) {
          x++;
          error += 2 * dy;
        } else if (octant == 2) {
          x--;
          error += 2 * dy;
        } else if (octant == 3) {
          x--;
          error += 2 * dy.abs();
        } else {
          x++;
          error += 2 * dy.abs();
        }
      } else {
        if (error >= 0) {
          if (octant == 1) {
            x++;
            error -= 2 * dy;
          } else if (octant == 2) {
            x--;
            error -= 2 * dy;
          } else if (octant == 3) {
            x--;
            error -= 2 * dy.abs();
          } else {
            x++;
            error -= 2 * dy.abs();
          }
        }

        if (octant == 1) {
          y++;
          error += 2 * dx;
        } else if (octant == 2) {
          y++;
          error += 2 * dx.abs();
        } else if (octant == 3) {
          y--;
          error += 2 * dx.abs();
        } else {
          y--;
          error += 2 * dx;
        }
      }
      i++;
      points.add(Point.vec2b(x, y));
    }

    return points;
  }

  List<Point> getLineVuPoints(Offset start, Offset end) {
    int x = start.dx.toInt();
    int y = start.dy.toInt();

    int dx = end.dx.toInt() - x;
    int dy = end.dy.toInt() - y;

    if (dx == 0 || dy == 0) {
      return getLineBresenhamPoints(start, end);
    }

    bool xIsLeading = dy.abs() < dx.abs();
    List<Point> points = [
      Point.vec2b(x, y),
      xIsLeading ? Point.vec2b(x, y + 1) : Point.vec2b(x + 1, y)
    ];

    int octant = 1;
    if (dx < 0 && dy > 0) {
      octant = 2;
    } else if (dx < 0 && dy < 0) {
      octant = 3;
    } else if (dx > 0 && dy < 0) {
      octant = 4;
    }

    // error = dy / dx - 1/2 ||| [-0.5, 0.5]
    // 2 * dx * error ||| [-1 * dx, dx]

    int error = xIsLeading ? 2 * dy - dx : 2 * dx - dy;

    int i = 1;
    while (xIsLeading && i < dx.abs() || !xIsLeading && i < dy.abs()) {
      int preError = error;

      if (xIsLeading) {
        if (error >= 0) {
          if (octant == 1) {
            y++;
            error -= 2 * dx;
          } else if (octant == 2) {
            y++;
            error -= 2 * dx.abs();
          } else if (octant == 3) {
            y--;
            error -= 2 * dx.abs();
          } else {
            y--;
            error -= 2 * dx;
          }
        }

        if (octant == 1) {
          x++;
          error += 2 * dy;
        } else if (octant == 2) {
          x--;
          error += 2 * dy;
        } else if (octant == 3) {
          x--;
          error += 2 * dy.abs();
        } else {
          x++;
          error += 2 * dy.abs();
        }
      } else {
        if (error >= 0) {
          if (octant == 1) {
            x++;
            error -= 2 * dy;
          } else if (octant == 2) {
            x--;
            error -= 2 * dy;
          } else if (octant == 3) {
            x--;
            error -= 2 * dy.abs();
          } else {
            x++;
            error -= 2 * dy.abs();
          }
        }

        if (octant == 1) {
          y++;
          error += 2 * dx;
        } else if (octant == 2) {
          y++;
          error += 2 * dx.abs();
        } else if (octant == 3) {
          y--;
          error += 2 * dx.abs();
        } else {
          y--;
          error += 2 * dx;
        }
      }
      i++;

      double opacity =
          (error / (xIsLeading ? 4 * dx.abs() : 4 * dy.abs()) + 1) / 2;
      if (xIsLeading) {
        points.add(Point.vec2(x, y + 1, Color.fromRGBO(0, 0, 0, 1 - opacity)));
        points.add(Point.vec2(x, y, Color.fromRGBO(0, 0, 0, opacity)));
      } else {
        // print(preError / dy.abs());
        points.add(Point.vec2(x + 1, y, Color.fromRGBO(0, 0, 0, 1 - opacity)));
        points.add(Point.vec2(x, y, Color.fromRGBO(0, 0, 0, opacity)));
      }
    }

    return points;
  }

  List<Point> getCircleBresenhamPoints(Offset start, Offset end) {
    List<Point> points = [];

    int radius =
        sqrt(pow(end.dx - start.dx, 2) + pow(end.dy - start.dy, 2)).toInt();

    int x = 0;
    int y = radius;

    int error = 2 - 2 * radius;

    points.add(Point.vec2b(x, y));

    while (y > 0) {
      int hError = error + 2 * x + 1;
      int dError = error + 2 * x - 2 * y + 2;
      int vError = error - 2 * y + 1;

      if (error < 0) {
        if (dError.abs() - hError.abs() < 0) {
          x += 1;
          y -= 1;
          error = dError;
        } else {
          x += 1;
          error = hError;
        }
      } else if (error > 0) {
        if (dError.abs() - vError.abs() < 0) {
          x += 1;
          y -= 1;
          error = dError;
        } else {
          y -= 1;
          error = vError;
        }
      } else {
        x += 1;
        y -= 1;
        error = dError;
      }

      points.add(Point.vec2b(x, y));
    }

    int firstOctant = points.length;
    for (int i = 0; i < firstOctant; i++) {
      Point currentPoint = points[i];
      points.add(Point.vec2b(-currentPoint.x + start.dx.toInt(),
          currentPoint.y + start.dy.toInt()));
      points.add(Point.vec2b(currentPoint.x + start.dx.toInt(),
          -currentPoint.y + start.dy.toInt()));
      points.add(Point.vec2b(-currentPoint.x + start.dx.toInt(),
          -currentPoint.y + start.dy.toInt()));
      currentPoint.x += start.dx.toInt();
      currentPoint.y += start.dy.toInt();
    }

    return points;
  }

  List<Point> getEllipsePoints(Offset start, Offset end) {
    List<Point> points = [];

    int a = (end.dx - start.dx).abs().toInt();
    int b = (end.dy - start.dy).abs().toInt();
    int radius = sqrt(b * b * pow(end.dx - start.dx, 2) +
            a * a * pow(end.dy - start.dy, 2))
        .toInt();

    int x = 0;
    int y = b;

    int error = a * a + b * b - 2 * a * b;
    // points.add(Point.vec2b(x, y));

    // First octant
    while (y > 0) {
      if (error < 0) {
        int delta = 2 * (error + a * a * y) - 1;

        if (delta <= 0) {
          x += 1;
          error += b * b * (2 * x + 1);
        } else {
          x += 1;
          y -= 1;
          error += b * b * (2 * x + 1) + a * a * (1 - 2 * y);
        }
      } else if (error > 0) {
        int delta = 2 * (error - b * b * x) - 1;
        if (delta <= 0) {
          x += 1;
          y -= 1;
          error += b * b * (2 * x + 1) + a * a * (1 - 2 * y);
        } else {
          y -= 1;
          error += a * a * (1 - 2 * y);
        }
      } else {
        x += 1;
        y -= 1;
        error += b * b * (2 * x + 1) + a * a * (1 - 2 * y);
      }

      points.add(Point.vec2b(x, y));
    }

    int firstOctant = points.length;
    for (int i = 0; i < firstOctant; i++) {
      Point currentPoint = points[i];
      points.add(Point.vec2b(-currentPoint.x + start.dx.toInt(),
          currentPoint.y + start.dy.toInt()));
      points.add(Point.vec2b(currentPoint.x + start.dx.toInt(),
          -currentPoint.y + start.dy.toInt()));
      points.add(Point.vec2b(-currentPoint.x + start.dx.toInt(),
          -currentPoint.y + start.dy.toInt()));
      currentPoint.x += start.dx.toInt();
      currentPoint.y += start.dy.toInt();
    }

    return points;
  }

  List<Point> getHyperbolaPoints(Offset start, Offset end) {
    List<Point> points = [];

    int x = 0;
    int y = 0;

    int a = (end.dx - start.dx).toInt();
    int a2 = a * a;

    int b = (end.dy - start.dy).abs().toInt();
    int b2 = b * b;

    int square(x) => x * x;

    int error = b2 * square(x.abs() + a) - a2 * square(y) - a2 * b2;
    while (x.abs() < a.abs()) {
      int hError = error + b2 * (2 * (x.abs() + a.abs()) - 1);
      int dError =
          error + b2 * (2 * (x.abs() + a.abs()) - 1) - a2 * (2 * y + 1);

      if (error >= 0) {
        x += (a >= 0) ? 1 : -1;
        y += 1;
        error = dError;
      } else {
        x += (a >= 0) ? 1 : -1;
        error = hError;
      }

      points.add(Point.vec2b(x + start.dx.toInt(), y + start.dy.toInt()));
      points.add(Point.vec2b(x + start.dx.toInt(), -y + start.dy.toInt()));
    }

    return points;
  }

  List<Point> getParabolaPoints(Offset start, Offset end) {
    List<Point> points = [];

    int x = 0;
    int y = 0;

    int a = (end.dy - start.dy).toInt();
    int b = (end.dx - start.dx).abs().toInt();
    int square(x) => x * x;

    // x2 = 4ay
    // x2 - 4ay = 0
    int error = 0;
    while (y.abs() < a.abs()) {
      int hError = square(x + 1) - a.abs() * y.abs();
      int vError = square(x) - a.abs() * (y.abs() + 1);

      if (error > 0) {
        y += (a >= 0) ? 1 : -1;
        error = vError;
      } else {
        x += 1;
        error = hError;
      }

      points.add(Point.vec2b(x + start.dx.toInt(), y + start.dy.toInt()));
      points.add(Point.vec2b(-x + start.dx.toInt(), y + start.dy.toInt()));
    }

    return points;
  }

  void _drawPointsWithColor(Canvas canvas, List<Point> points) {
    for (int i = 0; i < points.length; i++) {
      Offset point = points[i].getOffset();
      Paint brush = Paint()
        ..color = points[i].getColor()
        ..strokeWidth = 1;

      canvas.drawPoints(PointMode.points, [point], brush);
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    Paint brush = Paint()
      ..color = Colors.black
      ..strokeWidth = 1;

    List<Point> points = [];

    for (int i = 0; i < toDraw.length; i++) {
      GraphicalEditorAction action = toDraw[i];
      EditorAction method = action.action;

      Offset start = Offset(
          double.parse(action.arguments[0]), double.parse(action.arguments[1]));
      Offset end = Offset(
          double.parse(action.arguments[2]), double.parse(action.arguments[3]));

      if (method == EditorAction.lineDDA) {
        points.addAll(getLineDDAPoints(start, end));
      } else if (method == EditorAction.lineBresenham) {
        points.addAll(getLineBresenhamPoints(start, end));
      } else if (method == EditorAction.lineVu) {
        points.addAll(getLineVuPoints(start, end));
      } else if (method == EditorAction.circle) {
        points.addAll(getCircleBresenhamPoints(start, end));
      } else if (method == EditorAction.ellipse) {
        points.addAll(getEllipsePoints(start, end));
      } else if (method == EditorAction.hyperbola) {
        points.addAll(getHyperbolaPoints(start, end));
      } else if (method == EditorAction.parabola) {
        points.addAll(getParabolaPoints(start, end));
      }
    }

    if (toPlan.arguments.isNotEmpty) {
      Offset start = Offset(
          double.parse(toPlan.arguments[0]), double.parse(toPlan.arguments[1]));
      Offset end = Offset(
          double.parse(toPlan.arguments[2]), double.parse(toPlan.arguments[3]));

      if (toPlan.action == EditorAction.lineDDA) {
        points.addAll(getLineDDAPoints(start, end));
      } else if (toPlan.action == EditorAction.lineBresenham) {
        points.addAll(getLineBresenhamPoints(start, end));
      } else if (toPlan.action == EditorAction.lineVu) {
        points.addAll(getLineVuPoints(start, end));
      } else if (toPlan.action == EditorAction.circle) {
        points.addAll(getCircleBresenhamPoints(start, end));
      } else if (toPlan.action == EditorAction.ellipse) {
        points.addAll(getEllipsePoints(start, end));
      } else if (toPlan.action == EditorAction.hyperbola) {
        points.addAll(getHyperbolaPoints(start, end));
      } else if (toPlan.action == EditorAction.parabola) {
        points.addAll(getParabolaPoints(start, end));
      }
    }
    _drawPointsWithColor(canvas, points);
  }

  @override
  bool shouldRepaint(CustomPainter old) => true;
}

class GraphicalEditor extends StatefulWidget {
  GraphicalEditor({super.key});

  @override
  State<GraphicalEditor> createState() => _GraphicalEditorState();
}

class _GraphicalEditorState extends State<GraphicalEditor> {
  GraphicalEditorAction currentAction =
      GraphicalEditorAction(EditorAction.none);
  List<GraphicalEditorAction> actions = [];
  List<GraphicalEditorAction> canceled = [];

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

  Widget _getCanvas() => Expanded(
        child: Container(
            margin: EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(color: Colors.white, boxShadow: [
              const BoxShadow(
                  color: Colors.grey, spreadRadius: 1, blurRadius: 5),
            ]),
            child: GestureDetector(
              onPanStart: (var details) {
                setState(() {
                  currentAction.clearArguments();

                  currentAction
                      .addArgument(details.localPosition.dx.toString());
                  currentAction
                      .addArgument(details.localPosition.dy.toString());
                  currentAction
                      .addArgument(details.localPosition.dx.toString());
                  currentAction
                      .addArgument(details.localPosition.dy.toString());
                });
              },
              onPanUpdate: (var details) {
                setState(() {
                  currentAction.popArgument();
                  currentAction.popArgument();

                  currentAction
                      .addArgument(details.localPosition.dx.toString());
                  currentAction
                      .addArgument(details.localPosition.dy.toString());

                  // print("Updating end position");
                  // print(currentAction.arguments);
                });
              },
              onPanEnd: (var details) {
                setState(() {
                  if (currentAction.action != EditorAction.none) {
                    actions.add(currentAction);
                    canceled = [];
                  }
                  currentAction = GraphicalEditorAction(currentAction.action);
                });
              },
              child: ClipRect(
                child: CustomPaint(
                    foregroundPainter:
                        GraphicalEditorPainter(actions, currentAction),
                    child: Container(color: Colors.white)),
              ),
            )),
      );

  Widget _getToolStatusBar() => Container(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(color: Colors.transparent),
          child: Column(
            children: [
              Divider(height: 1.8, color: Colors.black, thickness: 1.8),
              _createKeyValueField("Инструмент:", currentAction.toString(),
                  startMargin: 12.0, endMargin: 10.0),
              Divider(height: 1.8, color: Colors.black, thickness: 1.8),
            ],
          ),
        ),
      );

  Widget _getToolBar() => MenuBar(
          style: MenuStyle(
              backgroundColor: MaterialStateColor.resolveWith((states) {
                return Colors.amberAccent.shade400;
              }),
              elevation: MaterialStatePropertyAll(0)),
          clipBehavior: Clip.hardEdge,
          children: [
            SubmenuButton(child: Text("Отрезки"), menuChildren: [
              MenuItemButton(
                  onPressed: () => setState(() {
                        currentAction =
                            GraphicalEditorAction(EditorAction.lineDDA);
                      }),
                  child: Text("Цифровой Дифференциальный Анализатор")),
              MenuItemButton(
                  onPressed: () => setState(() {
                        currentAction =
                            GraphicalEditorAction(EditorAction.lineBresenham);
                      }),
                  child: const Text("Брезенхема")),
              MenuItemButton(
                  onPressed: () => setState(() {
                        currentAction =
                            GraphicalEditorAction(EditorAction.lineVu);
                      }),
                  child: const Text("Ксиаолин Ву")),
            ]),
            SubmenuButton(child: Text("Линии 2-го порядка"), menuChildren: [
              MenuItemButton(
                  onPressed: () => setState(() {
                        currentAction =
                            GraphicalEditorAction(EditorAction.circle);
                      }),
                  child: const Text("Окружность")),
              MenuItemButton(
                  onPressed: () => setState(() {
                        currentAction =
                            GraphicalEditorAction(EditorAction.ellipse);
                      }),
                  child: const Text("Эллипс")),
              MenuItemButton(
                  onPressed: () => setState(() {
                        currentAction =
                            GraphicalEditorAction(EditorAction.hyperbola);
                      }),
                  child: const Text("Гипербола")),
              MenuItemButton(
                  onPressed: () => setState(() {
                        currentAction =
                            GraphicalEditorAction(EditorAction.parabola);
                      }),
                  child: const Text("Порабола")),
            ]),
          ]);

  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      AppBar(
        backgroundColor: Colors.amberAccent.shade400,
        foregroundColor: Colors.black,
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  canceled.add(actions.removeLast());
                });
              },
              icon: Icon(Icons.arrow_back, color: Colors.black)),
          IconButton(
              onPressed: () {
                setState(() {
                  actions.add(canceled.removeAt(0));
                });
              },
              icon: Icon(Icons.arrow_forward, color: Colors.black)),
          Expanded(child: Container()),
          IconButton(
              onPressed: () {
                setState(() {
                  actions = [];
                });
              },
              icon:
                  Icon(Icons.cleaning_services_outlined, color: Colors.black)),
        ],
      ),
      SizedBox(height: 10),
      _getCanvas(),
      SizedBox(height: 10),
      _getToolStatusBar(),
      _getToolBar(),
    ]);
  }
}
