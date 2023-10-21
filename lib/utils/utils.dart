import 'dart:collection';

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
}
