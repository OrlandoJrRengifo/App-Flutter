import '../../domain/entities/course.dart';

class CourseModel extends Course {
  CourseModel({
    super.id,
    required super.name,
    required super.code,
    required super.teacherId,
    required super.maxStudents,
    super.createdAt,
  });

  factory CourseModel.fromMap(Map<String, dynamic> m) {
    final parsedMax = m['max_students'] != null
        ? int.tryParse(m['max_students'].toString()) ?? 0
        : 0;

    print(
      "📦 fromMap → name=${m['name']} | max_students=${m['max_students']} | parsed=$parsedMax",
    );

    return CourseModel(
      id: m['_id']?.toString(),
      name: m['name'] as String,
      code: m['code'] as String,
      teacherId: m['teacher_id'] as String,
      createdAt: m['created_at'] != null && m['created_at'] != "null"
          ? DateTime.tryParse(m['created_at'].toString())
          : null,
      maxStudents: m['max_students'] != null
          ? int.tryParse(m['max_students'].toString()) ?? 0
          : 0,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'code': code,
      'teacher_id': teacherId,
      'max_students': maxStudents,
      'created_at': createdAt?.toIso8601String(),
    };
    if (id != null) map['_id'] = id;
    return map;
  }

  @override
  CourseModel copyWith({
    String? id,
    String? name,
    String? code,
    String? teacherId,
    int? maxStudents,
    DateTime? createdAt,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      teacherId: teacherId ?? this.teacherId,
      maxStudents: maxStudents ?? this.maxStudents,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
