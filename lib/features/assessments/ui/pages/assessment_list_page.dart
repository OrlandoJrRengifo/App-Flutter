import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/assessment_controller.dart';
import '../../domain/entities/assessment.dart';
import '../../../fake_users/ui/controller/fake_user_controller.dart';

class AssessmentListPage extends StatefulWidget {
  final String activityId;
  final String currentUserId;

  const AssessmentListPage({
    super.key,
    required this.activityId,
    required this.currentUserId,
  });

  @override
  State<AssessmentListPage> createState() => _AssessmentListPageState();
}

class _AssessmentListPageState extends State<AssessmentListPage> {
  final AssessmentController controller = Get.find();
  final FakeUserController userController = Get.find();

  late Future<void> _loadFuture;

  final Map<String, String> _userNames = {};

  @override
  void initState() {
    super.initState();
    _loadFuture = _loadData();
  }

  Future<void> _loadData() async {
    final assessments = await controller.getAssessmentsByActivityAndRater(
      widget.activityId,
      widget.currentUserId,
    );
    controller.assessments.assignAll(assessments);

    final ids = assessments.map((a) => a.toRate).toSet().toList();
    final users = await userController.getUsersByIds(ids);

    for (final u in users) {
      _userNames[u.authId] = u.name;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _loadFuture,
      builder: (_, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          appBar: AppBar(title: const Text("Assessments")),
          body: Obx(() {
            if (controller.assessments.isEmpty) {
              return const Center(child: Text("No assessments found"));
            }
            return ListView.builder(
              itemCount: controller.assessments.length,
              itemBuilder: (_, i) {
                final a = controller.assessments[i];
                final name = _userNames[a.toRate] ?? a.toRate;
                return ListTile(
                  title: Text("To rate: $name"),
                  subtitle: Text("Time: ${Assessment.formatTime(a.timeWin)}"),
                  trailing: const Icon(Icons.edit),
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(16),
                        ),
                      ),
                      builder: (_) => AssessmentRatingSheet(assessment: a),
                    );
                  },
                );
              },
            );
          }),
          floatingActionButton: Obx(() {
            if (controller.assessments.isEmpty) return const SizedBox.shrink();
            final first = controller.assessments.first;
            if (first.visibility != "public") return const SizedBox.shrink();

            return FloatingActionButton(
              child: const Icon(Icons.bar_chart),
              onPressed: () async {
                final avg = await controller.getAverageRatings(
                  widget.activityId,
                  widget.currentUserId,
                );
                showModalBottomSheet(
                  context: context,
                  builder: (_) => Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          "Average Ratings",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text("Punctuality: ${avg["punctuality"]?.toStringAsFixed(2)}"),
                        Text("Contributions: ${avg["contributions"]?.toStringAsFixed(2)}"),
                        Text("Commitment: ${avg["commitment"]?.toStringAsFixed(2)}"),
                        Text("Attitude: ${avg["attitude"]?.toStringAsFixed(2)}"),
                        Text("General: ${avg["general"]?.toStringAsFixed(2)}"),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        );
      },
    );
  }
}

class AssessmentRatingSheet extends StatefulWidget {
  final Assessment assessment;
  const AssessmentRatingSheet({super.key, required this.assessment});

  @override
  State<AssessmentRatingSheet> createState() => _AssessmentRatingSheetState();
}

class _AssessmentRatingSheetState extends State<AssessmentRatingSheet> {
  final AssessmentController controller = Get.find();

  final Map<String, int?> ratings = {
    "punctuality": null,
    "contributions": null,
    "commitment": null,
    "attitude": null,
  };

  final descriptions = {
    2: "Needs Improvement",
    3: "Adequate",
    4: "Good",
    5: "Excellent",
  };

  Widget buildRatingRow(String key, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
        Row(
          children: List.generate(5, (i) {
            final value = i + 1;
            return IconButton(
              icon: Icon(
                Icons.star,
                color: value >= 2 && value <= 5
                    ? (value <= (ratings[key] ?? 0) ? Colors.amber : Colors.grey)
                    : Colors.grey.shade300,
              ),
              onPressed: value >= 2
                  ? () => setState(() => ratings[key] = value)
                  : null,
            );
          }),
        ),
        if (ratings[key] != null)
          Text(
            descriptions[ratings[key]] ?? "",
            style: const TextStyle(fontSize: 12),
          ),
        const SizedBox(height: 12),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: MediaQuery.of(context).viewInsets,
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Grade ${widget.assessment.toRate}",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              buildRatingRow("punctuality", "Punctuality"),
              buildRatingRow("contributions", "Contributions"),
              buildRatingRow("commitment", "Commitment"),
              buildRatingRow("attitude", "Attitude"),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    child: const Text("Cancel"),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    child: const Text("Save"),
                    onPressed: () async {
                      if (ratings.values.any((v) => v == null)) {
                        Get.snackbar("Error", "All criteria must be rated");
                        return;
                      }
                      final ok = await controller.gradeAssessment(
                        widget.assessment.id!,
                        ratings["punctuality"]!,
                        ratings["contributions"]!,
                        ratings["commitment"]!,
                        ratings["attitude"]!,
                      );
                      if (ok) {
                        Navigator.pop(context);
                        Get.snackbar("Success", "Assessment graded!");
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
