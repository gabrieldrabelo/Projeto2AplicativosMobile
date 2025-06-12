class OrderPayment {
  int? id;
  int orderId;
  double value;
  String paymentType; // Tipo de pagamento (dinheiro, cartão, etc)
  String? description; // Descrição adicional

  OrderPayment({
    this.id,
    required this.orderId,
    required this.value,
    required this.paymentType,
    this.description,
  });

  // Getter para o valor do pagamento
  double get amount => value;

  factory OrderPayment.fromJson(Map<String, dynamic> json) {
    return OrderPayment(
      id: json['id'],
      orderId: json['idPedido'],
      value: json['valor']?.toDouble() ?? 0.0,
      paymentType: json['paymentType'] ?? 'Dinheiro',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idPedido': orderId,
      'valor': value,
      'paymentType': paymentType,
      'description': description,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'orderId': orderId,
      'value': value,
      'paymentType': paymentType,
      'description': description,
    };
  }

  factory OrderPayment.fromMap(Map<String, dynamic> map) {
    return OrderPayment(
      id: map['id'],
      orderId: map['orderId'],
      value: map['value'],
      paymentType: map['paymentType'] ?? 'Dinheiro',
      description: map['description'],
    );
  }
}