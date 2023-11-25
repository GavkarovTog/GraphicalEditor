import 'dart:math';
import 'package:flutter/material.dart';
import 'package:graphical_editor/utils/utils.dart';

List<Point> getLineDDAPoints(Offset start, Offset end,
    {Color color = Colors.black, int boldness = 1}) {
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

    points.add(Point.vec2cb(x.toInt(), y.toInt(), color, boldness));
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
    points.add(Point.vec2b(
        -currentPoint.x + start.dx.toInt(), currentPoint.y + start.dy.toInt()));
    points.add(Point.vec2b(
        currentPoint.x + start.dx.toInt(), -currentPoint.y + start.dy.toInt()));
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
  int radius = sqrt(
      b * b * pow(end.dx - start.dx, 2) + a * a * pow(end.dy - start.dy, 2))
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
    points.add(Point.vec2b(
        -currentPoint.x + start.dx.toInt(), currentPoint.y + start.dy.toInt()));
    points.add(Point.vec2b(
        currentPoint.x + start.dx.toInt(), -currentPoint.y + start.dy.toInt()));
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
    int dError = error + b2 * (2 * (x.abs() + a.abs()) - 1) - a2 * (2 * y + 1);

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

List<Point> getErmitPoints(Offset start, Offset end, Offset startSupport,
    Offset endSupport) {
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
  for (int i = startT; i <= endT; i++) {
    double t = i / (endT - startT).abs();

    int x = (t * t * t * (2 * startX - 2 * endX + startSX + endSX) +
        t * t * (-3 * startX + 3 * endX - 2 * startSX - endSX) +
        t * startSX +
        startX)
        .toInt();
    int y = (t * t * t * (2 * startY - 2 * endY + startSY + endSY) +
        t * t * (-3 * startY + 3 * endY - 2 * startSY - endSY) +
        t * startSY +
        startY)
        .toInt();

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

List<Point> getBezierPoints(Offset start, Offset end, Offset startSupport,
    Offset endSupport) {
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
  for (int i = startT; i <= endT; i++) {
    double t = i / (endT - startT).abs();

    // -1*P(1x) + 3 * P(2x) -3 P(3x) + P(4x)
    // 3P(1x) - 6P(2x) + 3P(3x)
    // -3P(1x) + 3P(3x)
    // P(1x)

    int x = (t * t * t * (-1 * startX + 3 * startSX - 3 * endSX + endX) +
        t * t * (3 * startX - 6 * startSX + 3 * endSX) +
        t * (-3 * startX + 3 * startSX) +
        startX)
        .toInt();
    int y = (t * t * t * (-1 * startY + 3 * startSY - 3 * endSY + endY) +
        t * t * (3 * startY - 6 * startSY + 3 * endSY) +
        t * (-3 * startY + 3 * startSY) +
        startY)
        .toInt();

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

List<Point> getBSplinePoints(Offset start, Offset end, Offset startSupport,
    Offset endSupport) {
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
  for (int i = startT; i <= endT; i++) {
    double t = i / (endT - startT).abs();

    // -1 P(1x) + 3 P(2x) -3 P(3x) + R(4x)
    // 3 P(1x) -6 P(2x) + 3 P(3x)
    // -3 P(1x) + 3 P(3x)
    // P(1x) + 4 P(2x) + P(3x)

    int x = (t * t * t * (-1 * startX + 3 * endX - 3 * startSX + endSX) +
        t * t * (3 * startX - 6 * endX + 3 * startSX) +
        t * (-3 * startX + 3 * startSX) +
        startX +
        4 * endX +
        startSX) ~/
        6;
    int y = (t * t * t * (-1 * startY + 3 * endY - 3 * startSY + endSY) +
        t * t * (3 * startY - 6 * endY + 3 * startSY) +
        t * (-3 * startY + 3 * startSY) +
        startY +
        4 * endY +
        startSY) ~/
        6;

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

List getGrahamShell(List<Offset> points) {
  List<Point> result = [];
  List<Offset> supportPoints = List.from(points);

  if (supportPoints.isEmpty) {
    return result;
  }

  List<Offset> minPoints = [];
  double? minY;
  for (Offset point in supportPoints) {
    if (minY == null) {
      minY = point.dy;
      continue;
    }

    if (minY > point.dy) {
      minY = point.dy;
    }
  }

  for (Offset point in supportPoints) {
    if (point.dy == minY) {
      minPoints.add(point);
    }
  }

  Offset? extremalPoint;
  for (Offset point in minPoints) {
    if (extremalPoint == null) {
      extremalPoint = point;
      continue;
    }

    if (extremalPoint.dx > point.dx) {
      extremalPoint = point;
    }
  }

  supportPoints.remove(extremalPoint);
  supportPoints.sort((left, right) {
    double diff = polarAngle(vecDiff(left, extremalPoint!)) -
        polarAngle(vecDiff(right, extremalPoint!));

    if (diff == 0) {
      diff = vecDist(
          vecDiff(left, extremalPoint!), vecDiff(right, extremalPoint!));
    }

    return diff.sign.toInt();
  });

  // print("===");
  // supportPoints.forEach((el) {
  //   print(atan((el.dy - extremalPoint!.dy) / (el.dx - extremalPoint!.dx)));
  // });
  // print("===");

  List<Offset> shellPoints = [
    extremalPoint!,
    if (supportPoints.isNotEmpty) supportPoints.removeAt(0)
  ];

  for (int i = 1; i < supportPoints.length; i++) {
    Offset point = supportPoints[i];

    while (shellPoints.length > 1 &&
        ((shellPoints[shellPoints.length - 1]).dx - point.dx) *
            (shellPoints[shellPoints.length - 2].dy - point.dy) -
            (shellPoints[shellPoints.length - 2].dx - point.dx) *
                ((shellPoints[shellPoints.length - 1]).dy - point.dy) <
            0) {
      shellPoints.removeLast();
    }

    shellPoints.add(point);
  }

  if (shellPoints.length == 1) {
    result.addAll(getLineDDAPoints(shellPoints[0], shellPoints[0]));
  } else {
    for (int i = 1; i < shellPoints.length; i++) {
      result.addAll(getLineDDAPoints(shellPoints[i - 1], shellPoints[i]));
    }

    result.addAll(
        getLineDDAPoints(shellPoints[0], shellPoints[shellPoints.length - 1]));
  }

  // PolygonPoll poll = PolygonPoll.getInstance();
  // poll.addPolygon(Polygon(shellPoints));

  return [result, shellPoints];
}

bool isLeft(Offset a, Offset b, Offset c) {
  return (b.dx - a.dx) * (c.dy - a.dy) - (b.dy - a.dy) * (c.dx - a.dx) > 0;
}

List getJarvisShell(List<Offset> points) {
  List<Point> result = [];
  List<Offset> hullPoints = [];

  Offset? leftmost;
  for (Offset point in points) {
    if (leftmost == null) {
      leftmost = point;
      continue;
    }

    if (leftmost.dx > point.dx) {
      leftmost = point;
    }
  }

  bool timeToStop = false;
  do {
    hullPoints.add(leftmost!);
    Offset endPoint = points[0];

    for (int i = 0; i < points.length; i++) {
      if (endPoint == leftmost ||
          isLeft(endPoint, hullPoints.last, points[i])) {
        endPoint = points[i];
      }
    }

    leftmost = endPoint;

    if (endPoint == hullPoints[0]) {
      timeToStop = true;
    }
  } while (!timeToStop);

  for (int i = 1; i < hullPoints.length; i++) {
    result.addAll(getLineDDAPoints(hullPoints[i - 1], hullPoints[i]));
  }

  result.addAll(
      getLineDDAPoints(hullPoints[0], hullPoints[hullPoints.length - 1]));

  // PolygonPoll poll = PolygonPoll.getInstance();
  // poll.addPolygon(Polygon(hullPoints.sublist(0, hullPoints.length - 1)));

  return [result, hullPoints];
}

// List<Point> getIntersectionLine(Offset start, Offset end) {
//   List<Polygon> polygons = PolygonPoll.getInstance().getPoll();
//   List<Point> result = [];
//
//   print("Count of polygons: ${polygons.length}");
//
//   int intervals_count = 100;
//   Offset incValue = Offset((end.dx - start.dx) / intervals_count,
//       (end.dy - start.dy) / intervals_count);
//
//   List<bool> intersectionValue = [];
//   List<Map> polyIn = [];
//
//   polygons.forEach((element) {
//     polyIn.add({});
//   });
//   for (int t = 1; t <= intervals_count; t++) {
//     Offset currentPoint = Offset(
//       start.dx + incValue.dx * t,
//       start.dy + incValue.dy * t
//     );
//     intersectionValue.add(false);
//
//     int polyCounter = 0;
//     for (Polygon poly in polygons) {
//       int sideCounter = 0;
//       for (Offset normal in poly.getNormals()) {
//         Offset F = Offset(poly.vertices[sideCounter].dx, poly.vertices[sideCounter].dy);
//         Offset vecDifference = Offset(currentPoint.dx - F.dx, currentPoint.dy - F.dy);
//         double scalarProduct = normal.dx * vecDifference.dx + normal.dy * vecDifference.dy;
//
//         bool? previousIn = polyIn[polyCounter][sideCounter];
//         if (scalarProduct > 0) {
//           polyIn[polyCounter][sideCounter] = true;
//         } else {
//           polyIn[polyCounter][sideCounter] = false;
//         }
//
//         if (previousIn != null && previousIn != polyIn[polyCounter][sideCounter]) {
//           // print("$polyCounter $sideCounter");
//           intersectionValue[t - 1] = true;
//         }
//
//         sideCounter ++;
//       }
//
//       polyCounter ++;
//     }
//   }
//
//
//   for (int t = 1; t <= intervals_count; t ++) {
//     Offset previousPoint = Offset(
//         start.dx + incValue.dx * (t - 1),
//         start.dy + incValue.dy * (t - 1)
//     );
//
//     Offset currentPoint = Offset(
//         start.dx + incValue.dx * t,
//         start.dy + incValue.dy * t
//     );
//
//
//     Color colorOfSegment = Colors.black;
//     int boldness = 1;
//
//     if (intersectionValue[t - 1]) {
//       colorOfSegment = Colors.green;
//       boldness = 10;
//     }
//
//     result.addAll(getLineDDAPoints(previousPoint, currentPoint, color: colorOfSegment, boldness: boldness));
//   }
//
//   return result;
// }

List<Point> getIntersectionLine(Offset start, Offset end) {
  List<Polygon> polygons = PolygonPoll.getInstance().getPoll();
  List<Point> result = [];

  List<Point> polygonPoints = [];
  for (Polygon poly in polygons) {
    polygonPoints.addAll(getPolygon(poly));
  }
  result.addAll(getLineDDAPoints(start, end));

  for (int i = 0; i < result.length; i ++) {
    Point currentPoint = result[i];
    Point newPoint = Point.vec2cb(
        currentPoint.x, currentPoint.y, Colors.green, 15);

    for (Point polyPoint in polygonPoints) {
      if (currentPoint.x == polyPoint.x && currentPoint.y == polyPoint.y) {
        result[i] = newPoint;
      }
    }
  }

  return result;
}

List<Point> getPolygon(Polygon poly) {
  List<Offset> vertices = poly.vertices;
  List<Point> result = [];

  for (int i = 1; i < vertices.length; i++) {
    result.addAll(getLineDDAPoints(vertices[i - 1], vertices[i]));
  }

  if (vertices.length != 0) {
    result.addAll(getLineDDAPoints(vertices[0], vertices[vertices.length - 1]));
  }
  return result;
}

bool containsBetweenY(List<Point> points, Point betweenPoint) {
  bool below = false;
  bool above = false;

  for (Point val in points) {
    if (betweenPoint.y <= val.y) {
      below = true;
    }

    if (betweenPoint.y >= val.y) {
      above = true;
    }

    if (below && above) {
      return true;
    }
  }

  return false;
}

bool containsBetweenX(List<Point> points, Point betweenPoint) {
  bool below = false;
  bool above = false;

  for (Point val in points) {
    if (betweenPoint.x <= val.x) {
      below = true;
    }

    if (betweenPoint.x >= val.x) {
      above = true;
    }

    if (below && above) {
      return true;
    }
  }

  return false;
}

bool isInPolygon(Polygon poly, Offset point) {
  List<Point> polyPoints = getPolygon(poly);

  List<Point> horizontal = getLineDDAPoints(Offset(point.dx + 1000, point.dy), Offset(point.dx - 1000, point.dy));
  List<Point> vertical = getLineDDAPoints(Offset(point.dx, point.dy + 1000), Offset(point.dx, point.dy - 1000));

  List<Point> horIntersection = [];
  List<Point> verIntersection = [];
  for (Point polyPoint in polyPoints) {
    for (Point horPoint in horizontal) {
      if (containsBetweenX(horIntersection, Point.vec2b(point.dx.toInt(), point.dy.toInt()))) {
        break;
      }

      if (polyPoint.x == horPoint.x && polyPoint.y == horPoint.y) {
        horIntersection.add(polyPoint);
      }
    }

    for (Point verPoint in vertical) {
      if (containsBetweenY(verIntersection, Point.vec2b(point.dx.toInt(), point.dy.toInt()))) {
        break;
      }

      if (polyPoint.x == verPoint.x && polyPoint.y == verPoint.y) {
        verIntersection.add(polyPoint);
      }
    }

    // print("<hor: $horCount");
    // print("ver: $verCount>");

    if (containsBetweenX(horIntersection, Point.vec2b(point.dx.toInt(), point.dy.toInt()))
        && containsBetweenY(verIntersection, Point.vec2b(point.dx.toInt(), point.dy.toInt()))) {
      return true;
    }
  }

  return false;
}

List<Point> getIndicatorPoint(Offset start) {
  List<Polygon> polygons = PolygonPoll.getInstance().getPoll();

  for (Polygon poly in polygons) {
    if (isInPolygon(poly, start)) {
      return [Point.vec2cb(start.dx.toInt(), start.dy.toInt(), Colors.green, 10)];
    }
  }

  return getLineDDAPoints(start, start);
}

List<Point> getFillWithOrderedEdges(Offset start) {
  List<Polygon> polygons = PolygonPoll.getInstance().getPoll();

  int selectedPoly = 0;
  for (Polygon poly in polygons) {
    if (isInPolygon(poly, start)) {
      break;
    }
  }

  if (selectedPoly == polygons.length) {
    return [];
  }

  Polygon polygon = polygons[selectedPoly];
  List<Offset> vertices = polygon.vertices;
  vertices.sort((fst, snd) => (fst.dy - snd.dy).toInt());

  List<List<Point>> scanningRows = [];
  for (int i = vertices[0].dy.toInt(); i < vertices.last.dy.toInt(); i ++) {
    scanningRows.add(getLineDDAPoints(Offset(start.dx + 1000, i.toDouble()), Offset(start.dx - 1000, i.toDouble())));
  }


  List<Offset> visitedVertices = [];
  List<Offset> intersections = [];
  for (int i = 0; i < vertices.length; i ++) {
    Offset previousVertex = vertices[i > 0 ? (i - 1) : vertices.length - 1];
    Offset currentVertex = vertices[i];
    Offset nextVertex = vertices[(i + 1) % vertices.length];

    bool local = false;
    if (currentVertex.dy < previousVertex.dy && currentVertex.dy < nextVertex.dy ||
        currentVertex.dy > previousVertex.dy && currentVertex.dy > nextVertex.dy) {
      local = true;
    } else if (currentVertex.dy == previousVertex.dy && currentVertex.dy == nextVertex.dy) {
      continue;
    }

    List<Point> currentEdge = getLineDDAPoints(currentVertex, nextVertex);

    for (List<Point> row in scanningRows) {
      List<Offset> rowIntersections = [];

      for (Point rowPoint in row) {
        for (Point edgePoint in currentEdge) {
          if (rowPoint.x == edgePoint.x && rowPoint.y == edgePoint.y) {
            if (!local && (edgePoint.x == currentVertex.dx && edgePoint.y == currentVertex.dy
                || edgePoint.x == nextVertex.dx && edgePoint.y == nextVertex.dy))
             {
              if (visitedVertices.contains(Offset(edgePoint.x.toDouble(), edgePoint.y.toDouble()))) {
                continue;
              }

              visitedVertices.add(Offset(edgePoint.x.toDouble(), edgePoint.y.toDouble()));
            }

            rowIntersections.add(Offset(rowPoint.x.toDouble(), rowPoint.y.toDouble()));
          }
        }
      }

      if (rowIntersections.length != 1) {
        intersections.addAll(rowIntersections);
      }
    }
  }

  intersections.sort(
      (fst, snd) {
        if (fst.dy < snd.dy || fst.dy == snd.dy && fst.dx <= snd.dx) {
          return -1;
        }

        return 1;
      }
  );


  List<List<Offset>> intervals = [];
  for (int i = 2; i <= intersections.length; i ++) {
    intervals.add(
      [intersections[i - 2], intersections[i - 1]]
    );
  }
  List<Point> result = [];
  for (List<Offset> interval in intervals) {
    result.addAll(
      getLineDDAPoints(interval[0], interval[1])
    );
  }

  return result;
}
