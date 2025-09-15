class Course {
  final int? id;
  final String name;
  final String code;
  final int teacherId;
  final int maxStudents;
  final DateTime? createdAt;

  Course({
    this.id,
    required this.name,
    required this.code,
    required this.teacherId,
    required this.maxStudents,
    this.createdAt,
  });

  Course copyWith({
    int? id,
    String? name,
    String? code,
    int? teacherId,
    int? maxStudents,
    DateTime? createdAt,
  }) {
    return Course(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      teacherId: teacherId ?? this.teacherId,
      maxStudents: maxStudents ?? this.maxStudents,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Course(id: $id, name: $name, code: $code, teacherId: $teacherId, maxStudents: $maxStudents)';
  }
}