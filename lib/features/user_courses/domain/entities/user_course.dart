class UserCourse {
  final int userId;
  final int courseId;

  UserCourse({required this.userId, required this.courseId});

  Map<String, dynamic> toJson() => {
        'user_id': userId,
        'course_id': courseId,
      };

  factory UserCourse.fromJson(Map<String, dynamic> json) => UserCourse(
        userId: json['user_id'],
        courseId: json['course_id'],
      );
}
