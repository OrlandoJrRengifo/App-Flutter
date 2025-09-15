import '../../domain/entities/course.dart';

class CourseModel extends Course {
  CourseModel({
    int? id,
    required String name,
    required String code,
    required int teacherId,
    required int maxStudents,
    DateTime? createdAt,
  }) : super(
          id: id,
          name: name,
          code: code,
          teacherId: teacherId,
          maxStudents: maxStudents,
          createdAt: createdAt,
        );

  factory CourseModel.fromMap(Map<String, dynamic> m) {
    return CourseModel(
      id: m['id'] is int ? m['id'] as int : (m['id'] != null ? int.parse(m['id'].toString()) : null),
      name: m['name'] as String,
      code: m['code'] as String,
      teacherId: m['teacherId'] is int ? m['teacherId'] as int : int.parse(m['teacherId'].toString()),
      maxStudents: m['maxStudents'] is int ? m['maxStudents'] as int : int.parse(m['maxStudents'].toString()),
      createdAt: m['createdAt'] != null ? DateTime.parse(m['createdAt'] as String) : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'code': code,
      'teacherId': teacherId,
      'maxStudents': maxStudents,
    };
    
    if (id != null) map['id'] = id;
    return map;
  }

  CourseModel copyWith({
    int? id,
    String? name,
    String? code,
    int? teacherId,
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