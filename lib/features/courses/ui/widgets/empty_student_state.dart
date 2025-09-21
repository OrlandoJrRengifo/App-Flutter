import 'package:flutter/material.dart';

class EmptyStudentState extends StatelessWidget {
  const EmptyStudentState({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Icon(Icons.group, size: 48, color: Colors.grey),
        SizedBox(height: 8),
        Text("No estás inscrito en cursos"),
      ]),
    );
  }
}
