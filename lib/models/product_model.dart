class ProductModel {
  final int? id;
  final String name;
  final String category;
  final String presentation; // Ej: '50 ml', '80 ml', '100 ml'
  final String origin; // [CAMPO_ESPECÍFICO_1] Ej: 'Francia', 'España', etc.
  final String variety; // [CAMPO_ESPECÍFICO_2] Ej: 'Eau de Parfum', 'Parfum', etc.
  final double price;
  final int stock;
  final String description;
  final String imageUrl;

  ProductModel({
    this.id,
    required this.name,
    required this.category,
    required this.presentation,
    required this.origin,
    required this.variety,
    required this.price,
    required this.stock,
    required this.description,
    required this.imageUrl,
  });

  bool get isAvailable => stock > 0;
  bool get isLowStock => stock > 0 && stock <= 3;

  /// Lista de imágenes asociadas al perfume (máximo 5).
  List<String> get images {
    final raw = imageUrl.trim();
    if (raw.isEmpty) return [];
    if (raw.contains('|')) {
      return raw
          .split('|')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
    }
    return [raw];
  }

  /// Imagen principal para catálogo y miniaturas.
  String get primaryImage => images.isNotEmpty ? images.first : imageUrl;

  /// Lista de presentaciones disponibles (ej: ['5 ml', '10 ml', '100 ml']).
  List<String> get presentations {
    final raw = presentation.trim();
    if (raw.isEmpty) return ['100 ml'];
    final delimiter = raw.contains('|') ? '|' : ',';
    final list = raw
        .split(delimiter)
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
    return list.isNotEmpty ? list : [raw];
  }

  /// Primera presentación por defecto.
  String get defaultPresentation =>
      presentations.isNotEmpty ? presentations.first : presentation;

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category': category,
      'presentation': presentation,
      'origin': origin,
      'variety': variety,
      'price': price,
      'stock': stock,
      'description': description,
      'image_url': imageUrl,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      category: map['category'] as String? ?? 'General',
      presentation: map['presentation'] as String? ?? '100 ml',
      origin: map['origin'] as String? ?? 'Francia',
      variety: map['variety'] as String? ?? 'Eau de Parfum',
      price: (map['price'] as num?)?.toDouble() ?? 0.0,
      stock: (map['stock'] as int?) ?? 0,
      description: map['description'] as String? ?? '',
      imageUrl: map['image_url'] as String? ?? '',
    );
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? category,
    String? presentation,
    String? origin,
    String? variety,
    double? price,
    int? stock,
    String? description,
    String? imageUrl,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      presentation: presentation ?? this.presentation,
      origin: origin ?? this.origin,
      variety: variety ?? this.variety,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }
}
