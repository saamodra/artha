class Category {
  final String id;
  final String name;
  final DateTime createdAt;

  Category({required this.id, required this.name, required this.createdAt});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String,
      name: json['name'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'created_at': createdAt.toIso8601String()};
  }

  @override
  String toString() {
    return 'Category(id: $id, name: $name, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Category && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
