class Product {
  int? id;
  String name;
  String unit; // un, cx, kg, lt, ml
  double stockQuantity;
  double salePrice;
  int status; // 0 - Active / 1 - Inactive
  double? cost;
  String? barcode;
  String? lastModified;

  Product({
    this.id,
    required this.name,
    required this.unit,
    required this.stockQuantity,
    required this.salePrice,
    required this.status,
    this.cost,
    this.barcode,
    this.lastModified,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['nome'] ?? json['name'],
      unit: json['unidade'] ?? json['unit'],
      stockQuantity: json['qtdEstoque']?.toDouble() ?? json['stockQuantity']?.toDouble() ?? 0.0,
      salePrice: json['precoVenda']?.toDouble() ?? json['salePrice']?.toDouble() ?? 0.0,
      status: json['Status'] ?? json['status'] ?? 0,
      cost: json['custo']?.toDouble() ?? json['cost']?.toDouble(),
      barcode: json['codigoBarra'] ?? json['barcode'],
      lastModified: json['ultimaAlteracao'] ?? json['lastModified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': name,
      'unidade': unit,
      'qtdEstoque': stockQuantity,
      'precoVenda': salePrice,
      'Status': status,
      'custo': cost,
      'codigoBarra': barcode,
      'ultimaAlteracao': lastModified,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'unit': unit,
      'stockQuantity': stockQuantity,
      'salePrice': salePrice,
      'status': status,
      'cost': cost,
      'barcode': barcode,
      'lastModified': lastModified,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      unit: map['unit'],
      stockQuantity: map['stockQuantity'],
      salePrice: map['salePrice'],
      status: map['status'],
      cost: map['cost'],
      barcode: map['barcode'],
      lastModified: map['lastModified'],
    );
  }
}