import 'package:flutter/material.dart';
import 'package:flutter_application_1/features/categories/ui/pages/categories_page.dart';
import 'studentsList_page.dart';

class CourseDetailPage extends StatefulWidget {
  final String courseId;
  final String courseName;

  const CourseDetailPage({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<CourseDetailPage> createState() => _CourseTabsPageState();
}

class _CourseTabsPageState extends State<CourseDetailPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.courseName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.people), text: "Estudiantes"),
            Tab(icon: Icon(Icons.category), text: "Categorías"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Página de estudiantes
          StudentslistPage(
            courseId: widget.courseId,
          ),

          // Página de categorías
          CategoriesPage(
            courseId: widget.courseId,
          ),
        ],
      ),
    );
  }
}
