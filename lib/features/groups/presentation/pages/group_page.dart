import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/group_controller.dart';
import '../../domain/entities/group.dart';

class GroupPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const GroupPage({
    super.key,
    required this.categoryId,
    required this.categoryName,
  });

  @override
  State<GroupPage> createState() => _GroupPageState();
}

class _GroupPageState extends State<GroupPage> {
  late final GroupController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.find<GroupController>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.fetchGroupsByCategory(widget.categoryId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Grupos - ${widget.categoryName}")),
      body: Obx(() {
        if (controller.loading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        if (controller.error.isNotEmpty) {
          return Center(child: Text("Error: ${controller.error}"));
        }

        if (controller.groups.isEmpty) {
          return const Center(child: Text("No hay grupos creados"));
        }

        return ListView.builder(
          itemCount: controller.groups.length,
          itemBuilder: (context, index) {
            final group = controller.groups[index];
            return Card(
              margin: const EdgeInsets.all(12),
              child: ListTile(
                leading: CircleAvatar(
                  child: Text(group['identifier_number'].toString()),
                ),
                title: Text("Grupo ${group['identifier_number']}"),
                subtitle: Text("Máx integrantes: ${group['max_members']}"),
              ),
            );
          },
        );
      }),
    );
  }
}
