import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/assessment_controller.dart';
import '../../../fake_users/ui/controller/fake_user_controller.dart';

class AssessmentsStatsPage extends StatefulWidget {
  final String activityId;
  const AssessmentsStatsPage({super.key, required this.activityId});

  @override
  State<AssessmentsStatsPage> createState() => _ActivityStatsPageState();
}

class _ActivityStatsPageState extends State<AssessmentsStatsPage> {
  final AssessmentController assessmentController = Get.find();
  final FakeUserController userController = Get.find();

  late Future<List<_UserStats>> _loadFuture;

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadStats();
  }

  Future<List<_UserStats>> _loadStats() async {
    // 1. Obtener todos los assessments de la actividad
    final assessments = await assessmentController.getAssessmentsByActivity(widget.activityId);

    // 2. Agrupar por `toRate`
    final Map<String, List<String>> grouped = {};
    for (final a in assessments) {
      grouped.putIfAbsent(a.toRate, () => []);
      grouped[a.toRate]!.add(a.id!);
    }

    // 3. Obtener los usuarios (para traer los nombres)
    final userIds = grouped.keys.toList();
    final users = await userController.getUsersByIds(userIds);

    // 4. Crear lista de resultados con estadísticas
    final List<_UserStats> results = [];
    for (final user in users) {
      final avg = await assessmentController.getAverageRatings(
        widget.activityId,
        user.authId,
      );

      results.add(_UserStats(
        userId: user.authId,
        userName: user.name,
        punctuality: avg["punctuality"] ?? 0,
        contributions: avg["contributions"] ?? 0,
        commitment: avg["commitment"] ?? 0,
        attitude: avg["attitude"] ?? 0,
        general: avg["general"] ?? 0,
      ));
    }

    return results;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Activity Stats")),
      body: FutureBuilder<List<_UserStats>>(
        future: _loadFuture,
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text("No stats available"));
          }

          final stats = snapshot.data!;
          return ListView.builder(
            itemCount: stats.length,
            itemBuilder: (_, i) {
              final s = stats[i];
              return Card(
                margin: const EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.userName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text("Punctuality: ${s.punctuality.toStringAsFixed(2)}"),
                      Text("Contributions: ${s.contributions.toStringAsFixed(2)}"),
                      Text("Commitment: ${s.commitment.toStringAsFixed(2)}"),
                      Text("Attitude: ${s.attitude.toStringAsFixed(2)}"),
                      const Divider(),
                      Text(
                        "General: ${s.general.toStringAsFixed(2)}",
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _UserStats {
  final String userId;
  final String userName;
  final double punctuality;
  final double contributions;
  final double commitment;
  final double attitude;
  final double general;

  _UserStats({
    required this.userId,
    required this.userName,
    required this.punctuality,
    required this.contributions,
    required this.commitment,
    required this.attitude,
    required this.general,
  });
}
