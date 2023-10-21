// ignore_for_file: no_logic_in_create_state

import 'package:flutter/material.dart';
import 'package:graphical_editor/utils/arguments.dart';
import 'package:graphical_editor/utils/tools.dart';
import 'package:graphical_editor/utils/utils.dart';

class ToolMenuBar extends StatefulWidget {
  ToolMenuBar(this.menuHierarchy, {super.key});

  final Map<String, List<ToolInfo>> menuHierarchy;
  ValueNotifier<ToolInfo> selected = ValueNotifier(ToolInfo.empty());

  @override
  State<ToolMenuBar> createState() => _ToolMenuBarState(menuHierarchy);
}

class _ToolMenuBarState extends State<ToolMenuBar> {
  _ToolMenuBarState(
      Map<String, List<ToolInfo>> hierarchy) : menuHierarchy = [] {

    for (var menuNames in hierarchy.keys) {
      List submenus = hierarchy[menuNames]!;
      List<Widget> menuItems = [];
      for (ToolInfo toolInfo in submenus) {
        menuItems.add(
            MenuItemButton(
                onPressed: ()  {
                  widget.selected.value = toolInfo;
                },
                child: Text(toolInfo.toolName)
        ));
      }

      menuHierarchy.add(
        SubmenuButton(menuChildren: menuItems, child: Text(menuNames))
      );
    }
  }

  List<Widget> menuHierarchy;

  @override
  Widget build(BuildContext context) {
    return MenuBar(
        style: MenuStyle(
            backgroundColor: MaterialStateColor.resolveWith((states) {
              return Colors.amberAccent.shade400;
            }),
            elevation: MaterialStatePropertyAll(0)),
        clipBehavior: Clip.hardEdge,
        children: menuHierarchy);
  }
}
