class Product {
  int? id;
  String code;
  String name;
  String unit;
  double price;
  double stock;
  String? description;
  String? lastModified;

  Product({
    this.id,
    required this.code,
    required this.name,
    required this.unit,
    required this.price,
    required this.stock,
    this.description,
    this.lastModified,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      code: json['code'] ?? json['codigo'] ?? '',
      name: json['name'] ?? json['nome'] ?? '',
      unit: json['unit'] ?? json['unidade'] ?? '',
      price: (json['price'] ?? json['preco'] ?? 0.0).toDouble(),
      stock: (json['stock'] ?? json['estoque'] ?? 0.0).toDouble(),
      description: json['description'] ?? json['descricao'],
      lastModified: json['lastModified'] ?? json['ultimaAlteracao'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': code,
      'nome': name,
      'unidade': unit,
      'preco': price,
      'estoque': stock,
      'descricao': description,
      'ultimaAlteracao': lastModified,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'unit': unit,
      'price': price,
      'stock': stock,
      'description': description,
      'lastModified': lastModified,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      code: map['code'],
      name: map['name'],
      unit: map['unit'],
      price: map['price'],
      stock: map['stock'],
      description: map['description'],
      lastModified: map['lastModified'],
    );
  }

  Product copyWith({
    int? id,
    String? code,
    String? name,
    String? unit,
    double? price,
    double? stock,
    String? description,
    String? lastModified,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      lastModified: lastModified ?? this.lastModified,
    );
  }
}