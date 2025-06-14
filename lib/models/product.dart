// ignore_for_file: recursive_getters

class Product {
  int? id;
  String code;
  String name;
  String unit;
  double stock;
  double salePrice;
  String? description;
  String? lastModified;
  double stockQuantity;
  int status;
  double? cost;
  String? barcode;

  Product({
    this.id,
    required this.code,
    required this.name,
    required this.unit,
    required this.stock,
    required this.salePrice,
    this.description,
    this.lastModified,
    required this.stockQuantity,
    required this.status,
    this.cost,
    this.barcode,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      code: json['code'] ?? json['codigo'] ?? '',
      name: json['name'] ?? json['nome'] ?? '',
      unit: json['unit'] ?? json['unidade'] ?? '',
      stock: (json['stock'] ?? json['estoque'] ?? 0.0).toDouble(),
      salePrice: (json['salePrice'] ?? 0.0).toDouble(),
      description: json['description'] ?? json['descricao'],
      lastModified: json['lastModified'] ?? json['ultimaAlteracao'],
      stockQuantity: (json['stockQuantity'] ?? 0.0).toDouble(),
      status: json['status'] ?? 0,
      cost: json['cost']?.toDouble(),
      barcode: json['barcode'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'codigo': code,
      'nome': name,
      'unidade': unit,
      'estoque': stock,
      'salePrice': salePrice,
      'descricao': description,
      'ultimaAlteracao': lastModified,
      'stockQuantity': stockQuantity,
      'status': status,
      'cost': cost,
      'barcode': barcode,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'code': code,
      'name': name,
      'unit': unit,
      'stock': stock,
      'salePrice': salePrice,
      'description': description,
      'lastModified': lastModified,
      'stockQuantity': stockQuantity,
      'status': status,
      'cost': cost,
      'barcode': barcode,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      code: map['code'] ?? '',
      name: map['name'] ?? '',
      unit: map['unit'] ?? '',
      stock: (map['stock'] ?? 0.0).toDouble(),
      salePrice: (map['salePrice'] ?? 0.0).toDouble(),
      description: map['description'],
      lastModified: map['lastModified'],
      stockQuantity: (map['stockQuantity'] ?? 0.0).toDouble(),
      status: map['status'] ?? 0,
      cost: map['cost']?.toDouble(),
      barcode: map['barcode'],
    );
  }

  Product copyWith({
    int? id,
    String? code,
    String? name,
    String? unit,
    double? stock,
    double? salePrice,
    String? description,
    String? lastModified,
    double? stockQuantity,
    int? status,
    double? cost,
    String? barcode,
  }) {
    return Product(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      unit: unit ?? this.unit,
      stock: stock ?? this.stock,
      salePrice: salePrice ?? this.salePrice,
      description: description ?? this.description,
      lastModified: lastModified ?? this.lastModified,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      status: status ?? this.status,
      cost: cost ?? this.cost,
      barcode: barcode ?? this.barcode,
    );
  }
}