import 'dart:ui';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:graphical_editor/graphical_editor_painter.dart';
import 'package:graphical_editor/utils.dart';

class GraphicalEditorApp extends StatefulWidget {
  GraphicalEditorApp({super.key});

  @override
  State<GraphicalEditorApp> createState() => _GraphicalEditorAppState();
}

class _GraphicalEditorAppState extends State<GraphicalEditorApp> {
  bool isCurveSupportVectorEditing = false;

  Point support1 = Point(0, 0, 0, 0, Colors.black);

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
                  if (!isCurveSupportVectorEditing) {
                    currentAction.clearArguments();

                    currentAction
                        .addArgument(details.localPosition.dx.toString());
                    currentAction
                        .addArgument(details.localPosition.dy.toString());
                    currentAction
                        .addArgument(details.localPosition.dx.toString());
                    currentAction
                        .addArgument(details.localPosition.dy.toString());
                  }
                });
              },
              onPanUpdate: (var details) {
                setState(() {
                  if (!isCurveSupportVectorEditing) {
                    currentAction.popArgument();
                    currentAction.popArgument();

                    currentAction
                        .addArgument(details.localPosition.dx.toString());
                    currentAction
                        .addArgument(details.localPosition.dy.toString());
                  }

                  // print("Updating end position");
                  // print(currentAction.arguments);
                });
              },
              onPanEnd: (var details) {
                setState(() {
                  if (!isCurveSupportVectorEditing) {
                    if (currentAction.action == EditorAction.Ermit) {
                      Scaffold.of(context).showBottomSheet((context) {
                        isCurveSupportVectorEditing = true;
                        TextEditingController x1Controller = TextEditingController(text: support1.x.toString());
                        TextEditingController y1Controller = TextEditingController(text: support1.y.toString());
                        TextEditingController x2Controller = TextEditingController(text: support1.z.toString());
                        TextEditingController y2Controller = TextEditingController(text: support1.p.toString());

                        return WillPopScope(
                          onWillPop: () async {
                            setState(() {
                              isCurveSupportVectorEditing = false;
                            });
                            return true;
                          },
                          child: Container(
                            padding: EdgeInsets.symmetric(vertical: 3),
                            color: Colors.white,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text("Ввод опорных векторов",
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold)),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                        width: 30,
                                        child: TextField(
                                          onChanged: (text) {
                                            support1.x = int.parse(text);
                                          },
                                          controller: x1Controller,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              labelText: "x1"),
                                        )),
                                    SizedBox(width: 20),
                                    Container(
                                        width: 30,
                                        child: TextField(
                                          onChanged: (text) {
                                            support1.y = int.parse(text);
                                          },
                                          controller: y1Controller,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              labelText: "y1"),
                                        )),
                                    SizedBox(width: 20),
                                    Container(
                                        width: 30,
                                        child: TextField(
                                          onChanged: (text) {
                                            support1.z = int.parse(text);
                                          },
                                          controller: x2Controller,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              labelText: "x2"),
                                        )),
                                    SizedBox(width: 20),
                                    Container(
                                        width: 30,
                                        child: TextField(
                                          onChanged: (text) {
                                            support1.p = int.parse(text);
                                          },
                                          controller: y2Controller,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                              labelText: "y2"),
                                        )),
                                    SizedBox(width: 30,),
                                    OutlinedButton(
                                      onPressed: () {
                                        actions.add(currentAction);
                                        canceled = [];
                                        currentAction = GraphicalEditorAction(currentAction.action);
                                        isCurveSupportVectorEditing = false;
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Готово"),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      }, enableDrag: false);
                    }

                    else if (currentAction.action != EditorAction.none) {
                      actions.add(currentAction);
                      canceled = [];
                      currentAction = GraphicalEditorAction(currentAction.action);
                    }
                  }
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
            SubmenuButton(child: Text("Кривые"), menuChildren: [
              MenuItemButton(
                  onPressed: () => setState(() {
                        currentAction =
                            GraphicalEditorAction(EditorAction.Ermit);
                      }),
                  child: const Text("Эрмита")),
              MenuItemButton(
                  onPressed: () => setState(() {
                        currentAction =
                            GraphicalEditorAction(EditorAction.Bezier);
                      }),
                  child: const Text("Безье")),
              MenuItemButton(
                  onPressed: () => setState(() {
                        currentAction =
                            GraphicalEditorAction(EditorAction.bspline);
                      }),
                  child: const Text("B-сплайн")),
            ]),
          ]);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        AppBar(
          backgroundColor: Colors.amberAccent.shade400,
          foregroundColor: Colors.black,
          automaticallyImplyLeading: false,
          actions: [
            IconButton(
                onPressed: isCurveSupportVectorEditing
                    ? null
                    : () {
                        setState(() {
                          canceled.add(actions.removeLast());
                        });
                      },
                icon: Icon(Icons.arrow_back,
                    color: isCurveSupportVectorEditing
                        ? Color.fromRGBO(80, 80, 80, 1.0)
                        : Colors.black)),
            IconButton(
                onPressed: isCurveSupportVectorEditing
                    ? null
                    : () {
                        setState(() {
                          actions.add(canceled.removeAt(0));
                        });
                      },
                icon: Icon(Icons.arrow_forward,
                    color: isCurveSupportVectorEditing
                        ? Color.fromRGBO(80, 80, 80, 1.0)
                        : Colors.black)),
            Expanded(child: Container()),
            IconButton(
                onPressed: isCurveSupportVectorEditing
                    ? null
                    : () {
                        setState(() {
                          actions = [];
                        });
                      },
                icon: Icon(Icons.cleaning_services_outlined,
                    color: isCurveSupportVectorEditing
                        ? Color.fromRGBO(80, 80, 80, 1.0)
                        : Colors.black)),
          ],
        ),
        SizedBox(height: 10),
        _getCanvas(),
        SizedBox(height: 10),
        _getToolStatusBar(),
        _getToolBar(),
      ]),
    );
  }
}
