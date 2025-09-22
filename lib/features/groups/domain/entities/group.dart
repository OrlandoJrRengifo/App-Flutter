class Group {
  final String id;
  final String categoryId;
  final int numeration;
  int capacity;

  Group({
    required this.id,
    required this.categoryId,
    required this.numeration,
    required this.capacity,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
        id: json['id'] as String,
        categoryId: json['category_id'] as String,
        numeration: json['numeration'] as int,
        capacity: json['capacity'] as int,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "category_id": categoryId,
        "numeration": numeration,
        "capacity": capacity,
      };
}
