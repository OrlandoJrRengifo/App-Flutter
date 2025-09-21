import 'package:flutter/material.dart';

class EmptyTeachingState extends StatelessWidget {
  final VoidCallback onCreateCourse;

  const EmptyTeachingState({super.key, required this.onCreateCourse});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.book, size: 48, color: Colors.grey),
        const SizedBox(height: 8),
        const Text("Aún no tienes cursos"),
        const SizedBox(height: 8),
        ElevatedButton.icon(onPressed: onCreateCourse, icon: const Icon(Icons.add), label: const Text("Crear")),
      ]),
    );
  }
}
