import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:graphical_editor/utils/arguments.dart';
import 'package:graphical_editor/utils/tools.dart';

class Point {
  int x;
  int y;
  int z = 0;
  int p = 1;
  int boldness = 1;

  Color color = Colors.black;

  Point(this.x, this.y, this.z, this.p, this.color);

  Point.vec2(this.x, this.y, this.color);

  Point.vec2cb(this.x, this.y, this.color, this.boldness);

  Point.vec2b(this.x, this.y);

  Point.vec3(this.x, this.y, this.z, this.color);

  Offset getOffset() => Offset(x.toDouble(), y.toDouble());

  Color getColor() => color;

  @override
  String toString() {
    return "Point($x, $y)";
  }
}

class PolygonPoll {
  List<Polygon> _poll = [];
  static PolygonPoll? _instance;

  PolygonPoll._();

  static PolygonPoll getInstance() {
    _instance ??= PolygonPoll._();

    return _instance!;
  }

  List<Polygon> getPoll() {
    return _poll;
  }

  void addPolygon(Polygon poly) {
    _poll.add(poly);
  }

  void reset() {
    _poll = [];
  }
}

class Polygon {
  List<Offset> vertices = [];
  Polygon(this.vertices);

  List<Offset> getNormals() {
    List<Offset> normals = [];

    if (vertices.length < 3) {
      return [];
    }

    for (int i = 0; i < vertices.length; i ++) {
      Offset fst = vertices[i];

      late Offset snd;
      late Offset thd;

      if (i == vertices.length - 2) {
        snd = vertices[i + 1];
        thd = vertices[0];
      } else if (i == vertices.length - 1) {
        snd = vertices[0];
        thd = vertices[1];
      } else {
        snd = vertices[i + 1];
        thd = vertices[i + 2];
      }

      Offset ViVi1 = Offset(snd.dx - fst.dx, snd.dy - fst.dy);
      Offset ViVi2 = Offset(thd.dx - fst.dx, thd.dy - fst.dy);

      Offset normal = Offset(-ViVi1.dy, -ViVi1.dx);

      // Vx Vy
      // Ux Uy
      // VxUy - UxVy
      if (normal.dx * ViVi2.dy - normal.dy * ViVi2.dx >= 0) {
        normals.add(normal);
      } else {
        normals.add(Offset(-normal.dx, -normal.dy));
      }
    }

    return normals;
  }
}

double polarAngle(Offset point) {
  return atan(point.dx / point.dy);
}

Offset vecDiff(Offset left, Offset right) {
  return Offset(left.dx - right.dx, left.dy - right.dy);
}

double vecDist(Offset fst, Offset snd) {
  return sqrt(pow(fst.dx - snd.dx, 2) + pow(fst.dy - snd.dy, 2));
}
