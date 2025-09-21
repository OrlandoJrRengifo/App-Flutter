import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 Para copiar al portapapeles
import 'package:get/get.dart';
import '../../domain/entities/course.dart';
import '../pages/course_detail_page.dart';

class CourseCard extends StatelessWidget {
  final Course course;
  final void Function(Course)? onEdit;
  final void Function(Course)? onDelete;

  const CourseCard({
    super.key,
    required this.course,
    this.onEdit,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final formattedDate = course.createdAt != null
        ? "${course.createdAt!.day}/${course.createdAt!.month}/${course.createdAt!.year}"
        : "Sin fecha";

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: InkWell(
        onTap: () => Get.to(
          () => CourseDetailPage(
            courseId: course.id ?? "",
            courseName: course.name,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      course.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  if (onEdit != null && onDelete != null)
                    PopupMenuButton(
                      itemBuilder: (_) => [
                        PopupMenuItem(
                          child: const Text("Editar"),
                          onTap: () => Future.delayed(
                            const Duration(milliseconds: 100),
                            () => onEdit!(course),
                          ),
                        ),
                        PopupMenuItem(
                          child: const Text("Eliminar"),
                          onTap: () => Future.delayed(
                            const Duration(milliseconds: 100),
                            () => onDelete!(course),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text("Código: ${course.code}"),
                  ),
                  IconButton(
                    icon: const Icon(Icons.copy, size: 20),
                    tooltip: "Copiar código",
                    onPressed: () {
                      Clipboard.setData(
                        ClipboardData(text: course.code),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Código copiado")),
                      );
                    },
                  ),
                ],
              ),
              Text("Cupos: ${course.maxStudents}"),
              Text(formattedDate),
            ],
          ),
        ),
      ),
    );
  }
}
