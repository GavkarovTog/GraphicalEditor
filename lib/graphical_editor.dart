import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphical_editor/drawing_input_manager.dart';
import 'package:graphical_editor/graphical_editor_painter.dart';
import 'package:graphical_editor/tool_menu_bar.dart';
import 'package:graphical_editor/tool_status_bar.dart';
import 'package:graphical_editor/utils/tool_history.dart';
import 'package:graphical_editor/utils/arguments.dart';
import 'package:graphical_editor/utils/tools.dart';
import 'package:graphical_editor/utils/utils.dart';

class GraphicalEditorApp extends StatefulWidget {
  GraphicalEditorApp({super.key});

  @override
  State<GraphicalEditorApp> createState() => _GraphicalEditorAppState();
}

class _GraphicalEditorAppState extends State<GraphicalEditorApp> {
  final ToolMenuBar _menuBar = ToolMenuBar({
    "Прямые": [
      ToolInfo("ЦДА", DDALine(), RectangularInput()),
      ToolInfo("Брезенхем", BresenhamLine(), RectangularInput()),
      ToolInfo("Ву", VuLine(), RectangularInput()),
    ],
    "Кривые второго порядка": [
      ToolInfo("Окружность", CircleTool(), RectangularInput()),
      ToolInfo("Эллипс", EllipseTool(), RectangularInput()),
      ToolInfo("Гипербола", HyperbolaTool(), RectangularInput()),
      ToolInfo("Парабола", ParabolaTool(), RectangularInput()),
    ],
    "Параметрические кривые": [
      ToolInfo("Эрмита", ErmitTool(), RectangularInputWithTwoSupportVectors()),
      ToolInfo("Безье", BezierTool(), RectangularInputWithTwoSupportPoints()),
      ToolInfo("B-сплайн", BSplineTool(), MultigonalInput()),
    ],
    "Полигоны": [
      ToolInfo("Грэхэма", GrahamTool(), MultigonalInput(isGraham: true)),
      ToolInfo("Джарвиса", JarvisTool(), MultigonalInput(isJarvis: true)),
      ToolInfo("Пересечение", IntersectionLineTool(), RectangularInput()),
      ToolInfo("Принадлежность", IndicatorPointTool(), SinglePointInput()),
      ToolInfo("Закрашивание(уп. ребра)", FillWithOrderedEdgesTool(), SinglePointInput()),
      ToolInfo("Закрашивание(затравка)", FillWithPoint(), SinglePointInput()),
    ]
  });
  ToolHistory toolUsageHistory = ToolHistory();
  // late ToolInfo currentTool = _menuBar.selected.value;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ValueListenableBuilder<ToolInfo>(
        valueListenable: _menuBar.selected,
        builder: (context, selectedToolInfo, _) =>
            Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          AppBar(
            backgroundColor: Colors.amberAccent.shade400,
            foregroundColor: Colors.black,
            automaticallyImplyLeading: false,
            actions: [
              IconButton(
                  onPressed: () {
                    setState(() {
                      toolUsageHistory.back();
                    });
                  },
                  icon: Icon(Icons.arrow_back, color: Colors.black)),
              IconButton(
                  onPressed: () {
                    setState(() {
                      toolUsageHistory.forward();
                    });
                  },
                  icon: Icon(Icons.arrow_forward, color: Colors.black)),
              Expanded(child: Container()),
              IconButton(
                  onPressed: () {
                    setState(() {
                      toolUsageHistory.reset();
                      PolygonPoll.getInstance().reset();
                    });
                  },
                  icon: Icon(Icons.cleaning_services_outlined,
                      color: Colors.black)),
            ],
          ),
          SizedBox(height: 10),
          DrawingInputManager(toolUsageHistory, selectedToolInfo),
          SizedBox(height: 10),
          ToolStatusBar(selectedToolInfo),
          _menuBar,
        ]),
      ),
    );
  }
}
