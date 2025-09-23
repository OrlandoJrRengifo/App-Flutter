import 'package:flutter/material.dart';
import '../../../groups/ui/pages/groups_page.dart';
import '../../../activities/ui/pages/activities_page.dart';

class CategoryTabsPage extends StatefulWidget {
  final String categoryId;
  final String categoryName;
  final int defaultGroupCapacity;

  const CategoryTabsPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
    required this.defaultGroupCapacity,
  });

  @override
  State<CategoryTabsPage> createState() => _CategoryTabsPageState();
}

class _CategoryTabsPageState extends State<CategoryTabsPage>
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
        title: Text(widget.categoryName),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.group), text: "Grupos"),
            Tab(icon: Icon(Icons.task), text: "Actividades"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          GroupsPage(
            categoryId: widget.categoryId,
            defaultCapacity: widget.defaultGroupCapacity,
          ),
          ActivitiesPage(
            categoryId: widget.categoryId,
            categoryName: widget.categoryName,
          ),
        ],
      ),
    );
  }
}
