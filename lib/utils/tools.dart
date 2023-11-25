import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphical_editor/utils/arguments.dart';
import 'package:graphical_editor/utils/graphical_algorithms.dart';
import 'package:graphical_editor/utils/utils.dart';

class ToolInfo {
  ToolInfo(this.toolName, this.tool, this.inputMethod);
  ToolInfo.empty() : toolName = "Отсутствует", tool = Empty(), inputMethod = RectangularInput();
  String toolName;

  ToolBehaviour tool;
  ArgumentsInputBehaviour inputMethod;
}

abstract class ToolBehaviour {
  void supportPaint(List<Point> points, Arguments arguments) {}
  void paint(List<Point> points, Arguments arguments);
}

class Empty implements ToolBehaviour {
  void supportPaint(List<Point> points, Arguments arguments) {}

  @override
  void paint(List<Point> points, Arguments arguments) {}
}

class DDALine implements ToolBehaviour {
  void supportPaint(List<Point> points, Arguments arguments) {}

  @override
  void paint(List<Point> points, Arguments arguments) {
    points.addAll(getLineDDAPoints(arguments.get("start"), arguments.get("end")));
  }
}

class BresenhamLine implements ToolBehaviour {
  void supportPaint(List<Point> points, Arguments arguments) {}

  @override
  void paint(List<Point> points, Arguments arguments) {
    points.addAll(getLineBresenhamPoints(arguments.get("start"), arguments.get("end")));
  }
}

class VuLine implements ToolBehaviour {
  void supportPaint(List<Point> points, Arguments arguments) {}

  @override
  void paint(List<Point> points, Arguments arguments) {
    points.addAll(getLineVuPoints(arguments.get("start"), arguments.get("end")));
  }
}

class CircleTool implements ToolBehaviour {
  void supportPaint(List<Point> points, Arguments arguments) {}

  @override
  void paint(List<Point> points, Arguments arguments) {
    points.addAll(getCircleBresenhamPoints(arguments.get("start"), arguments.get("end")));
  }
}

class EllipseTool implements ToolBehaviour {
  void supportPaint(List<Point> points, Arguments arguments) {}

  @override
  void paint(List<Point> points, Arguments arguments) {
    points.addAll(getEllipsePoints(arguments.get("start"), arguments.get("end")));
  }
}

class HyperbolaTool implements ToolBehaviour {
  void supportPaint(List<Point> points, Arguments arguments) {}

  @override
  void paint(List<Point> points, Arguments arguments) {
    points.addAll(getHyperbolaPoints(arguments.get("start"), arguments.get("end")));
  }
}

class ParabolaTool implements ToolBehaviour {
  void supportPaint(List<Point> points, Arguments arguments) {}

  @override
  void paint(List<Point> points, Arguments arguments) {
    points.addAll(getParabolaPoints(arguments.get("start"), arguments.get("end")));
  }
}

class ErmitTool implements ToolBehaviour {
  void supportPaint(List<Point> points, Arguments arguments) {
    if (arguments.get("cycled")) {
      Offset start = arguments.get("support_start");
      Offset end = arguments.get("support_end");

      points.add(Point.vec2cb(
          start.dx.toInt(), start.dy.toInt(), Colors.blueAccent, 10));
      points.add(
          Point.vec2cb(end.dx.toInt(), end.dy.toInt(), Colors.blueAccent, 10));

      points.addAll(getLineDDAPoints(arguments.get("start"), start, color: Colors.red));
      points.addAll(getLineDDAPoints(arguments.get("end"), end, color: Colors.red));
    }
  }

  @override
  void paint(List<Point> points, Arguments arguments) {
    Offset startSupport = arguments.get("support_start") - arguments.get("start");
    Offset endSupport = arguments.get("support_end") - arguments.get("start");

    points.addAll(getErmitPoints(arguments.get("start"), arguments.get("end"), startSupport, endSupport));
  }
}

class BezierTool implements ToolBehaviour {
  void supportPaint(List<Point> points, Arguments arguments) {
    if (arguments.get("cycled")) {
      Offset start = arguments.get("support_start");
      Offset end = arguments.get("support_end");

      points.add(Point.vec2cb(
          start.dx.toInt(), start.dy.toInt(), Colors.blueAccent, 10));
      points.add(
          Point.vec2cb(end.dx.toInt(), end.dy.toInt(), Colors.blueAccent, 10));
    }
  }

  @override
  void paint(List<Point> points, Arguments arguments) {
    Offset startSupport = arguments.get("support_start");
    Offset endSupport = arguments.get("support_end");

    points.addAll(getBezierPoints(arguments.get("start"), arguments.get("end"), startSupport, endSupport));
  }
}

class BSplineTool implements ToolBehaviour {
  @override
  void supportPaint(List<Point> points, Arguments arguments) {
    if (arguments.get("cycled")) {
      List<Offset> supportPoints = arguments.get("points");
      // for (int i = 0; i < supportPoints.length; i ++) {
      //   if (i != supportPoints.length - 1) {
      //     points.add(Point.vec2cb(
      //         supportPoints[i].dx.toInt(), supportPoints[i].dy.toInt(),
      //         Colors.redAccent, 10));
      //   } else {
      //     points.add(Point.vec2cb(
      //         supportPoints[i].dx.toInt(), supportPoints[i].dy.toInt(),
      //         Colors.blueAccent, 10));
      //   }
      // }

      if (supportPoints.isNotEmpty) {
        points.add(Point.vec2cb(
            supportPoints[supportPoints.length - 1].dx.toInt(),
            supportPoints[supportPoints.length - 1].dy.toInt(),
            Colors.blueAccent, 10));
      }
    }
  }

  @override
  void paint(List<Point> points, Arguments arguments) {
    List<Offset> supportPoints = arguments.get("points");

    for (int i = 1; i < supportPoints.length; i ++) {
      points.addAll(
          getBSplinePoints(
              supportPoints[i - 1],
              supportPoints[i],
              supportPoints[(i + 1) % supportPoints.length],
              supportPoints[(i + 2) % supportPoints.length]
          ));
    }
  }
}

class GrahamTool implements ToolBehaviour {
  @override
  void supportPaint(List<Point> points, Arguments arguments) {
    if (arguments.get("cycled")) {
      List<Offset> supportPoints = arguments.get("points");
      for (int i = 0; i < supportPoints.length; i ++) {
        if (i != supportPoints.length - 1) {
          points.add(Point.vec2cb(
              supportPoints[i].dx.toInt(), supportPoints[i].dy.toInt(),
              Colors.redAccent, 10));
        } else {
          points.add(Point.vec2cb(
              supportPoints[i].dx.toInt(), supportPoints[i].dy.toInt(),
              Colors.blueAccent, 10));
        }
      }

      if (supportPoints.isNotEmpty) {
        points.add(Point.vec2cb(
            supportPoints[supportPoints.length - 1].dx.toInt(),
            supportPoints[supportPoints.length - 1].dy.toInt(),
            Colors.blueAccent, 10));
      }
    }
  }

  @override
  void paint(List<Point> points, Arguments arguments) {
    List<Offset> args = arguments.get("points");

    if (args.isNotEmpty) {
      points.addAll(getGrahamShell(args)[0]);
    }
  }
}

class JarvisTool implements ToolBehaviour {
  @override
  void supportPaint(List<Point> points, Arguments arguments) {
    if (arguments.get("cycled")) {
      List<Offset> supportPoints = arguments.get("points");
      for (int i = 0; i < supportPoints.length; i ++) {
        if (i != supportPoints.length - 1) {
          points.add(Point.vec2cb(
              supportPoints[i].dx.toInt(), supportPoints[i].dy.toInt(),
              Colors.redAccent, 10));
        } else {
          points.add(Point.vec2cb(
              supportPoints[i].dx.toInt(), supportPoints[i].dy.toInt(),
              Colors.blueAccent, 10));
        }
      }

      if (supportPoints.isNotEmpty) {
        points.add(Point.vec2cb(
            supportPoints[supportPoints.length - 1].dx.toInt(),
            supportPoints[supportPoints.length - 1].dy.toInt(),
            Colors.blueAccent, 10));
      }
    }
  }

  @override
  void paint(List<Point> points, Arguments arguments) {
    List<Offset> args = arguments.get("points");

    if (args.isNotEmpty) {
      points.addAll(getJarvisShell(args)[0]);
    }
  }
}

class IntersectionLineTool implements ToolBehaviour {
  @override
  void supportPaint(List<Point> points, Arguments arguments) {
    // if (arguments.get("cycled")) {
    //   List<Offset> supportPoints = arguments.get("points");
    //   for (int i = 0; i < supportPoints.length; i ++) {
    //     if (i != supportPoints.length - 1) {
    //       points.add(Point.vec2cb(
    //           supportPoints[i].dx.toInt(), supportPoints[i].dy.toInt(),
    //           Colors.redAccent, 10));
    //     } else {
    //       points.add(Point.vec2cb(
    //           supportPoints[i].dx.toInt(), supportPoints[i].dy.toInt(),
    //           Colors.blueAccent, 10));
    //     }
    //   }
    //
    //   if (supportPoints.isNotEmpty) {
    //     points.add(Point.vec2cb(
    //         supportPoints[supportPoints.length - 1].dx.toInt(),
    //         supportPoints[supportPoints.length - 1].dy.toInt(),
    //         Colors.blueAccent, 10));
    //   }
    // }
  }

  @override
  void paint(List<Point> points, Arguments arguments) {
    Offset start = arguments.get("start");
    Offset end = arguments.get("end");

    points.addAll(getIntersectionLine(start, end));
  }
}

class IndicatorPointTool implements ToolBehaviour {
  @override
  void supportPaint(List<Point> points, Arguments arguments) {
  }

  @override
  void paint(List<Point> points, Arguments arguments) {
    Offset start = arguments.get("start");
    points.addAll(getIndicatorPoint(start));
  }
}

class FillWithOrderedEdgesTool implements ToolBehaviour {
  @override
  void supportPaint(List<Point> points, Arguments arguments) {
  }

  @override
  void paint(List<Point> points, Arguments arguments) {
    Offset start = arguments.get("start");

    List<Polygon> polygons = PolygonPoll.getInstance().getPoll();

    for (Polygon poly in polygons) {
      if (isInPolygon(poly, start)) {
        points.addAll(getFillWithOrderedEdges(start));
        break;
      }
    }
  }
}