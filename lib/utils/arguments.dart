import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

abstract class ArgumentsInputBehaviour {
  Arguments arguments = Arguments();
  bool isReady = false;
  bool isCycled = false;
  bool isPolygon = false;
  bool isJarvis = false;
  bool isGraham = false;

  void onInputStart(DragStartDetails details);
  void onInputUpdate(DragUpdateDetails details);
  void onInputEnd(DragEndDetails details);
  ArgumentsInputBehaviour reset();
}

class RectangularInput extends ArgumentsInputBehaviour {
  RectangularInput() {
    arguments.set("start", Offset(-10, -10));
    arguments.set("end", Offset(-10, -10));
  }

  @override
  void onInputStart(DragStartDetails details) {
    arguments.set("start", Offset(details.localPosition.dx, details.localPosition.dy));
    arguments.set("end", Offset(details.localPosition.dx, details.localPosition.dy));
  }

  @override
  void onInputUpdate(DragUpdateDetails details) {
    arguments.set("end", Offset(details.localPosition.dx, details.localPosition.dy));
  }

  @override
  void onInputEnd(DragEndDetails details) {
    super.isReady = true;
  }

  @override
  ArgumentsInputBehaviour reset() {
    return RectangularInput();
  }
}

class RectangularInputWithTwoSupportVectors extends RectangularInput {
  bool startSupportDragged = false;
  bool endSupportDragged = false;

  RectangularInputWithTwoSupportVectors() : super() {
    arguments.set("support_start", Offset(0, 0));
    arguments.set("support_end", Offset(0, 0));
    arguments.set("cycled", false);
  }

  @override
  void onInputStart(DragStartDetails details) {
    if (! this.isCycled) {
      super.onInputStart(details);
      arguments.set("support_start", arguments.get("start"));
      arguments.set("support_end", arguments.get("start"));
    } else {
      Offset support_start = arguments.get("support_start");
      Offset support_end = arguments.get("support_end");

      if ((support_start.dx - details.localPosition.dx).abs() < 10 &&
          (support_start.dy - details.localPosition.dy).abs() < 10) {
        startSupportDragged = true;
      } else if ((support_end.dx - details.localPosition.dx).abs() < 10 &&
          (support_end.dy - details.localPosition.dy).abs() < 10) {
        endSupportDragged = true;
      }

      if (! startSupportDragged && ! endSupportDragged) {
        arguments.set("cycled", false);
        super.isReady = true;
      }
    }
  }

  @override
  void onInputUpdate(DragUpdateDetails details) {
    if (! this.isCycled) {
      super.onInputUpdate(details);
      arguments.set("support_start", arguments.get("start"));
      arguments.set("support_end", arguments.get("end"));
    } else {

      if (startSupportDragged) {
        arguments.set("support_start", Offset(details.localPosition.dx, details.localPosition.dy));
      } else if (endSupportDragged) {
        arguments.set("support_end", Offset(details.localPosition.dx, details.localPosition.dy));
      }
    }
  }

  @override
  void onInputEnd(DragEndDetails details) {
    if (! isCycled) {
      isCycled = true;
      arguments.set("cycled", true);
      arguments.set("support_start", arguments.get("start"));
      arguments.set("support_end", arguments.get("end"));
    }

    startSupportDragged = false;
    endSupportDragged = false;
  }

  @override
  ArgumentsInputBehaviour reset() {
    return RectangularInputWithTwoSupportVectors();
  }
}

class RectangularInputWithTwoSupportPoints extends RectangularInput {
  bool firstPointSelection = false;
  bool secondPointSelection = false;

  RectangularInputWithTwoSupportPoints() : super() {
    arguments.set("support_start", Offset(0, 0));
    arguments.set("support_end", Offset(0, 0));
    arguments.set("cycled", false);
  }

  @override
  void onInputStart(DragStartDetails details) {
    if (! isCycled) {
      super.onInputStart(details);
      arguments.set("support_start", arguments.get("start"));
      arguments.set("support_end", arguments.get("start"));
    } else {
      if (firstPointSelection) {
        arguments.set("support_start", Offset(details.localPosition.dx, details.localPosition.dy));
      } else {
        arguments.set("support_end", Offset(details.localPosition.dx, details.localPosition.dy));
      }
    }
  }

  @override
  void onInputUpdate(DragUpdateDetails details) {
    if (! isCycled) {
      super.onInputUpdate(details);
      arguments.set("support_start", arguments.get("start"));
      arguments.set("support_end", arguments.get("end"));
    }

    if (firstPointSelection) {
      arguments.set("support_start", Offset(details.localPosition.dx, details.localPosition.dy));
    } else if (secondPointSelection) {
      arguments.set("support_end", Offset(details.localPosition.dx, details.localPosition.dy));
    }
  }

  @override
  void onInputEnd(DragEndDetails details) {
    if (! isCycled) {
      isCycled = true;
      arguments.set("cycled", true);
      firstPointSelection = true;
    }  else if (firstPointSelection) {
      firstPointSelection = false;
      secondPointSelection = true;
    } else if (secondPointSelection) {
      secondPointSelection = false;
      arguments.set("cycled", false);
      isReady = true;
    }
  }

  @override
  ArgumentsInputBehaviour reset() {
    return RectangularInputWithTwoSupportPoints();
  }
}

class SinglePointInput extends ArgumentsInputBehaviour {
  SinglePointInput() {
    arguments.set("start", Offset(-10, -10));
  }

  @override
  void onInputStart(DragStartDetails details) {
    arguments.set("start", Offset(details.localPosition.dx, details.localPosition.dy));
  }

  @override
  void onInputUpdate(DragUpdateDetails details) {
  }

  @override
  void onInputEnd(DragEndDetails details) {
    super.isReady = true;
  }

  @override
  ArgumentsInputBehaviour reset() {
    return SinglePointInput();
  }
}

class MultigonalInput extends RectangularInput {
  List<Offset> points = [];
  Offset currentPoint = Offset(0, 0);

  MultigonalInput({bool isGraham = false, bool isJarvis = false}) : super() {
    super.isPolygon = isGraham || isJarvis;
    super.isGraham = isGraham;
    super.isJarvis = isJarvis;
    arguments.set("points", points);
    arguments.set("cycled", true);
    arguments.set("closured", false);
  }

  @override
  void onInputStart(DragStartDetails details) {
    currentPoint = Offset(details.localPosition.dx, details.localPosition.dy);

    bool toAddPoint = true;
    int index = 0;
    for (Offset point in points) {
      Offset subtraction = point - currentPoint;

      if (subtraction.dx.abs() < 10 && subtraction.dy.abs() < 10) {
        isCycled = false;
        arguments.set("cycled", false);
        toAddPoint = false;
        isReady = true;

        if (isReady) {
          arguments.set("ready", true);
        }

        if (point != points[points.length - 1]) {
          arguments.set("closured", true);
          arguments.set("closure_index", index);
        }

        break;
      }

      index ++;
    }

    if (toAddPoint) {
      points.add(currentPoint);
    }
  }

  @override
  void onInputUpdate(DragUpdateDetails details) {
    if (isCycled) {
      currentPoint = Offset(details.localPosition.dx, details.localPosition.dy);
      points[points.length - 1] = currentPoint;
    }
  }

  @override
  void onInputEnd(DragEndDetails details) {
  }

  @override
  ArgumentsInputBehaviour reset() {
    return MultigonalInput(isGraham: super.isGraham, isJarvis: super.isJarvis);
  }
}

class Arguments {
  Arguments() : arguments = <String, dynamic>{};
  Arguments.fromMap(this.arguments);

  Map<String, dynamic> arguments;

  void set(String key, dynamic value) {
    arguments[key] = value;
  }

  dynamic get(String key) {
    return arguments[key];
  }
}
