class OrderPayment {
  int? id;
  int orderId;
  double value;

  OrderPayment({
    this.id,
    required this.orderId,
    required this.value,
  });

  factory OrderPayment.fromJson(Map<String, dynamic> json) {
    return OrderPayment(
      id: json['id'],
      orderId: json['idPedido'],
      value: json['valor']?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPedido': orderId,
      'valor': value,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'value': value,
    };
  }

  factory OrderPayment.fromMap(Map<String, dynamic> map) {
    return OrderPayment(
      id: map['id'],
      orderId: map['orderId'],
      value: map['value'],
    );
  }
}