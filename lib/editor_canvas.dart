import 'package:flutter/material.dart';

class EditorCanvas extends StatelessWidget {
  const EditorCanvas({super.key});

  @override
  Widget build(BuildContext context) {
    return Expanded(
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
    );;
  }
}
