class Label {
  final String id;
  final String name;
  final int? color; // Flutter 32-bit color (0 to 4,294,967,295)
  final DateTime createdAt;

  Label({
    required this.id,
    required this.name,
    this.color,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  Map<String, dynamic> toSupabaseJson() {
    return {
      'id': id,
      'name': name,
      'color': color,
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory Label.fromJson(Map<String, dynamic> json) {
    return Label(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  factory Label.fromSupabaseJson(Map<String, dynamic> json) {
    return Label(
      id: json['id'],
      name: json['name'],
      color: json['color'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Label copyWith({String? id, String? name, int? color, DateTime? createdAt}) {
    return Label(
      id: id ?? this.id,
      name: name ?? this.name,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Label && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() {
    return 'Label(id: $id, name: $name, color: $color, createdAt: $createdAt)';
  }
}
