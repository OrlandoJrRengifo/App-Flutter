import '../../domain/entities/course.dart';

class CourseModel extends Course {
  CourseModel({
    String? id,
    required String name,
    required String code,
    required String teacherId,
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
      id: m['_id']?.toString(), 
      name: m['name'] as String,
      code: m['code'] as String,
      teacherId: m['teacher_id'] as String, 
      maxStudents: m['maxStudents'] != null
          ? int.tryParse(m['maxStudents'].toString()) ?? 0
          : 0,
      createdAt: m['created_at'] != null && m['created_at'] != "null"
          ? DateTime.tryParse(m['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'name': name,
      'code': code,
      'teacher_id': teacherId,
      'maxStudents': maxStudents,
    };
    if (id != null) map['_id'] = id;
    return map;
  }

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
