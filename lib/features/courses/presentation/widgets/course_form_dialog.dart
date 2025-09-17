import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../domain/entities/course.dart';

class CourseFormDialog extends StatefulWidget {
  final Course? course;
  
  const CourseFormDialog({this.course, super.key});

  @override
  _CourseFormDialogState createState() => _CourseFormDialogState();
}

class _CourseFormDialogState extends State<CourseFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _code;
  late final TextEditingController _maxStudents;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.course?.name ?? '');
    _code = TextEditingController(text: widget.course?.code ?? '');
    _maxStudents = TextEditingController(
      text: (widget.course?.maxStudents ?? 1).toString(),
    );
  }

  @override
  void dispose() {
    _name.dispose();
    _code.dispose();
    _maxStudents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        widget.course == null ? 'Crear curso' : 'Editar curso',
      ),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _name,
              decoration: const InputDecoration(
                labelText: 'Nombre del curso',
                hintText: 'Ej: Matemáticas Aplicadas',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Nombre obligatorio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _code,
              decoration: const InputDecoration(
                labelText: 'Código del curso',
                hintText: 'Ej: MAT2024',
              ),
              validator: (v) => v == null || v.trim().isEmpty ? 'Código obligatorio' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _maxStudents,
              decoration: const InputDecoration(
                labelText: 'Cupos máximos',
                hintText: 'Mínimo 1 estudiante',
              ),
              keyboardType: TextInputType.number,
              validator: (v) {
                final value = int.tryParse(v ?? '') ?? 0;
                return value < 1 ? 'Mínimo 1 cupo' : null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text('Cancelar')
        ),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final course = Course(
                id: widget.course?.id,
                name: _name.text.trim(),
                code: _code.text.trim(),
                teacherId: widget.course?.teacherId ?? "hola", // id de prueba, tiene que ser el del usuario logeado
                maxStudents: int.parse(_maxStudents.text),
                createdAt: widget.course?.createdAt,
              );
              
              Get.back(result: course);
            }
          },
          child: const Text('Crear'),
        ),
      ],
    );
  }
}