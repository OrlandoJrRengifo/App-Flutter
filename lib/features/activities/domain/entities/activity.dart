class Activity {
  final String? id; // Opcional porque Roble lo genera
  final String categoryId;
  String name;
  bool activated;

  Activity({
    this.id,
    required this.categoryId,
    required this.name,
    this.activated = false,
  });

  Map<String, Object?> toMap() {
    final map = <String, Object?>{
      "category_id": categoryId,
      "name": name,
      "activated": activated,
    };
    if (id != null) map['_id'] = id; // Object? permite null
    return map;
  }

  factory Activity.fromMap(Map<String, dynamic> map) {
    return Activity(
      id: map["_id"]?.toString(),
      categoryId: map["category_id"],
      name: map["name"],
      activated: map["activated"] ?? false,
    );
  }
}
