import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graphical_editor/utils/utils.dart';

List<Point> getLineDDAPoints(Offset start, Offset end, {Color color=Colors.black}) {
  List<Point> points = [];

  if (start == end) {
    return [Point.vec2b(start.dx.toInt(), start.dy.toInt())];
  }

  double length = max((end.dx - start.dx).abs(), (end.dy - start.dy).abs());

  double dx = (end.dx - start.dx) / length;
  double dy = (end.dy - start.dy) / length;

  double x = start.dx.round().toDouble();
  double y = start.dy.round().toDouble();

  points.add(Point.vec2(x.toInt(), y.toInt(), color));

  int i = 0;
  while (i <= length) {
    x = x + dx;
    y = y + dy;

    points.add(Point.vec2(x.toInt(), y.toInt(), color));
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

  if (dx == 0 || dy == 0) {
    return getLineDDAPoints(start, end);
  }

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

List<Point> getErmitPoints(Offset start, Offset end, Offset startSupport, Offset endSupport) {
  // 2P(1x) - 2 P(4x) + R(1x) + R(4x) | 2P(1y) - 2 P(4y) + R(1y) + R(4y)
  // -3P(1x) + 3P(4x) -2R(1x) - R(4x) | -3P(1y) + 3 P(4y) - 2R(1y) - R(4y)
  // R(1x) | R(1y)
  // P(1x) | P(1y)

  // x(t) =
  //  t^3(2P(1x) - 2 P(4x) + R(1x) + R(4x))
  //  + t^2(-3P(1x) + 3P(4x) -2R(1x) - R(4x))
  //  + t*R(1x)
  //  + P(1x)

  // y(t) =
  // t^3(2P(1y) - 2 P(4y) + R(1y) + R(4y))
  // + t^2(-3P(1y) + 3 P(4y) - 2R(1y) - R(4y)
  // + t*R(1y)
  // + P(1y)

  List<Point> points = [];

  int startX = start.dx.toInt();
  int startY = start.dy.toInt();
  int endX = end.dx.toInt();
  int endY = end.dy.toInt();

  int startSX = startSupport.dx.toInt();
  int startSY = startSupport.dy.toInt();

  int endSX = endSupport.dx.toInt();
  int endSY = endSupport.dy.toInt();

  int previousX = -1;
  int previousY = -1;

  int startT = 0;
  int endT = 10;
  for (int i = startT; i <= endT; i ++) {
    double t = i / (endT - startT).abs();

    int x = (t * t * t * (2 * startX - 2 * endX + startSX + endSX) +
            t * t * (-3 * startX + 3 * endX - 2 * startSX - endSX) +
            t * startSX +
            startX).toInt();
    int y = (t * t * t * (2 * startY - 2 * endY + startSY + endSY) +
        t * t * (-3 * startY + 3 * endY - 2 * startSY - endSY) +
        t * startSY +
        startY).toInt();

    if (i > 0) {
      points.addAll(getLineDDAPoints(
          Offset(previousX.toDouble(), previousY.toDouble()),
          Offset(x.toDouble(), y.toDouble())));
    }
    previousX = x;
    previousY = y;
  }

  return points;
}

List<Point> getBezierPoints(Offset start, Offset end, Offset startSupport, Offset endSupport) {
  List<Point> points = [];

  int startX = start.dx.toInt();
  int startY = start.dy.toInt();
  int endX = end.dx.toInt();
  int endY = end.dy.toInt();

  int startSX = startSupport.dx.toInt();
  int startSY = startSupport.dy.toInt();

  int endSX = endSupport.dx.toInt();
  int endSY = endSupport.dy.toInt();

  int previousX = -1;
  int previousY = -1;

  int startT = 0;
  int endT = 10;
  for (int i = startT; i <= endT; i ++) {
    double t = i / (endT - startT).abs();

    // -1*P(1x) + 3 * P(2x) -3 P(3x) + P(4x)
    // 3P(1x) - 6P(2x) + 3P(3x)
    // -3P(1x) + 3P(3x)
    // P(1x)

    int x = (t * t * t * (-1 * startX + 3 * startSX - 3 * endSX + endX) +
            t * t * (3 * startX - 6 * startSX + 3 * endSX) +
            t * (-3 * startX + 3 * startSX) +
            startX).toInt();
    int y = (t * t * t * (-1 * startY + 3 * startSY - 3 * endSY + endY) +
        t * t * (3 * startY - 6 * startSY + 3 * endSY) +
        t * (-3 * startY + 3 * startSY) +
        startY).toInt();

    if (i > 0) {
      points.addAll(getLineDDAPoints(
          Offset(previousX.toDouble(), previousY.toDouble()),
          Offset(x.toDouble(), y.toDouble())));
    }
    previousX = x;
    previousY = y;
  }

  return points;
}

List<Point> getBSplinePoints(Offset start, Offset end, Offset startSupport, Offset endSupport) {
  List<Point> points = [];

  int startX = start.dx.toInt();
  int startY = start.dy.toInt();
  int endX = end.dx.toInt();
  int endY = end.dy.toInt();

  int startSX = startSupport.dx.toInt();
  int startSY = startSupport.dy.toInt();

  int endSX = endSupport.dx.toInt();
  int endSY = endSupport.dy.toInt();

  int previousX = -1;
  int previousY = -1;

  int startT = 0;
  int endT = 10;
  for (int i = startT; i <= endT; i ++) {
    double t = i / (endT - startT).abs();

    // -1 P(1x) + 3 P(2x) -3 P(3x) + R(4x)
    // 3 P(1x) -6 P(2x) + 3 P(3x)
    // -3 P(1x) + 3 P(3x)
    // P(1x) + 4 P(2x) + P(3x)

    int x = (t * t * t * (-1 * startX + 3 * endX - 3 * startSX + endSX) +
        t * t * (3 * startX - 6 * endX + 3 * startSX) +
        t * (-3 * startX + 3 * startSX) +
        startX + 4 * endX + startSX) ~/ 6;
    int y = (t * t * t * (-1 * startY + 3 * endY - 3 * startSY + endSY) +
        t * t * (3 * startY - 6 * endY + 3 * startSY) +
        t * (-3 * startY + 3 * startSY) +
        startY + 4 * endY + startSY) ~/ 6;

    if (i > 0) {
      points.addAll(getLineDDAPoints(
          Offset(previousX.toDouble(), previousY.toDouble()),
          Offset(x.toDouble(), y.toDouble())));
    }
    previousX = x;
    previousY = y;
  }

  return points;
}