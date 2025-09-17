class Group {
  final int? id;
  final int categoryId;
  final int identifierNumber;
  final int maxMembers;
  final DateTime createdAt;

  Group({
    this.id,
    required this.categoryId,
    required this.identifierNumber,
    required this.maxMembers,
    required this.createdAt,
  });

  Group copyWith({
    int? id,
    int? categoryId,
    int? identifierNumber,
    int? maxMembers,
    DateTime? createdAt,
  }) {
    return Group(
      id: id ?? this.id,
      categoryId: categoryId ?? this.categoryId,
      identifierNumber: identifierNumber ?? this.identifierNumber,
      maxMembers: maxMembers ?? this.maxMembers,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
