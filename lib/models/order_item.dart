class OrderItem {
  int? id;
  int orderId;
  int productId;
  double quantity;
  double totalItem;
  String? productName; // Nome do produto para exibiu00e7u00e3o
  double price; // Preu00e7o unitu00e1rio
  String unit; // Unidade de medida

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.totalItem,
    this.productName,
    required this.price,
    required this.unit,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['idPedido'],
      productId: json['idProduto'],
      quantity: json['quantidade']?.toDouble() ?? 0.0,
      totalItem: json['totalItem']?.toDouble() ?? 0.0,
      productName: json['productName'],
      price: json['price']?.toDouble() ?? 0.0,
      unit: json['unit'] ?? 'un',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPedido': orderId,
      'idProduto': productId,
      'quantidade': quantity,
      'totalItem': totalItem,
      'productName': productName,
      'price': price,
      'unit': unit,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'totalItem': totalItem,
      'productName': productName,
      'price': price,
      'unit': unit,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      orderId: map['orderId'],
      productId: map['productId'],
      quantity: map['quantity'],
      totalItem: map['totalItem'],
      productName: map['productName'],
      price: map['price'] ?? 0.0,
      unit: map['unit'] ?? 'un',
    );
  }
}