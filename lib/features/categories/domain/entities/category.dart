enum GroupingMethod { random, selfAssigned }

class Category {
  final int? id;
  final int courseId;
  final String name;
  final GroupingMethod groupingMethod;
  final int? maxGroupSize;
  final DateTime? createdAt;

  Category({
    this.id,
    required this.courseId,
    required this.name,
    required this.groupingMethod,
    this.maxGroupSize,
    this.createdAt,
  });

  Category copyWith({
    int? id,
    int? courseId,
    String? name,
    GroupingMethod? groupingMethod,
    int? maxGroupSize,
    DateTime? createdAt,
  }) {
    return Category(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      groupingMethod: groupingMethod ?? this.groupingMethod,
      maxGroupSize: maxGroupSize ?? this.maxGroupSize,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
