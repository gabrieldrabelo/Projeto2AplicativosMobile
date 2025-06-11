class OrderItem {
  int? id;
  int orderId;
  int productId;
  double quantity;
  double totalItem;

  OrderItem({
    this.id,
    required this.orderId,
    required this.productId,
    required this.quantity,
    required this.totalItem,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['id'],
      orderId: json['idPedido'],
      productId: json['idProduto'],
      quantity: json['quantidade']?.toDouble() ?? 0.0,
      totalItem: json['totalItem']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPedido': orderId,
      'idProduto': productId,
      'quantidade': quantity,
      'totalItem': totalItem,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'productId': productId,
      'quantity': quantity,
      'totalItem': totalItem,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      id: map['id'],
      orderId: map['orderId'],
      productId: map['productId'],
      quantity: map['quantity'],
      totalItem: map['totalItem'],
    );
  }
}