import '../../domain/entities/category.dart';

class CategoryModel extends Category {
  CategoryModel({
    super.id,
    required super.courseId,
    required super.name,
    required super.groupingMethod,
    super.maxGroupSize,
    super.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> m) {
    final idValue = m['id'];
    final String? id = idValue == null
        ? null
        : (idValue is String ? idValue : idValue.toString());

    final courseRaw = m['courseId'];
    final courseId = courseRaw is String
        ? courseRaw
        : courseRaw.toString();

    final name = (m['name'] ?? '').toString();

    // groupingMethod: manejar explícitamente 'random' y 'self_assigned', fallback seguro
    final groupingStr = (m['groupingMethod'] ?? '').toString();
    final groupingMethod = groupingStr == 'random'
        ? GroupingMethod.random
        : groupingStr == 'self_assigned'
            ? GroupingMethod.selfAssigned
            : GroupingMethod.selfAssigned;

    final maxRaw = m['maxGroupSize'];
    final int? maxGroupSize = maxRaw == null
        ? null
        : (maxRaw is int ? maxRaw : int.tryParse(maxRaw.toString()));

    final createdRaw = m['createdAt'];
    final DateTime? createdAt = createdRaw == null
        ? null
        : (createdRaw is DateTime
            ? createdRaw
            : DateTime.tryParse(createdRaw.toString()));

    return CategoryModel(
      id: id,
      courseId: courseId,
      name: name,
      groupingMethod: groupingMethod,
      maxGroupSize: maxGroupSize,
      createdAt: createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'courseId': courseId,
      'name': name,
      'groupingMethod':
          groupingMethod == GroupingMethod.random ? 'random' : 'self_assigned',
      'maxGroupSize': maxGroupSize,
    };

    if (id != null) map['id'] = id;
    if (createdAt != null) map['createdAt'] = createdAt!.toIso8601String();
    return map;
  }

  @override
  CategoryModel copyWith({
    String? id,
    String? courseId,
    String? name,
    GroupingMethod? groupingMethod,
    int? maxGroupSize,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      name: name ?? this.name,
      groupingMethod: groupingMethod ?? this.groupingMethod,
      maxGroupSize: maxGroupSize ?? this.maxGroupSize,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
