import 'package:flutter/material.dart';
import 'package:graphical_editor/graphical_editor.dart';

void main() {
  runApp(AppContent());
}

class AppContent extends StatelessWidget {
  const AppContent({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange)
        ),
        home: Scaffold(
            body: GraphicalEditor()));
  }
}
