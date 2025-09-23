class UserGroup {
  final String id; 
  final String userId;
  final String groupId;

  UserGroup({
    required this.id,
    required this.userId,
    required this.groupId,
  });

  Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "group_id": groupId,
      };

  factory UserGroup.fromJson(Map<String, dynamic> json) => UserGroup(
        id: json["id"],
        userId: json["user_id"],
        groupId: json["group_id"],
      );
}
