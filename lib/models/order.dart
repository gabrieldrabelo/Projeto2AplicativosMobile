import 'order_item.dart';
import 'order_payment.dart';

class Order {
  int? id;
  int clientId;
  int userId;
  double totalOrder;
  String creationDate;
  String? lastModified;
  List<OrderItem> items;
  List<OrderPayment> payments;

  Order({
    this.id,
    required this.clientId,
    required this.userId,
    required this.totalOrder,
    required this.creationDate,
    this.lastModified,
    this.items = const [],
    this.payments = const [],
    required String clientName,
    required String orderDate,
    required double total,
    String? notes,
    required int status,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    List<OrderItem> items = [];
    if (json['itens'] != null) {
      items = List<OrderItem>.from(
          json['itens'].map((item) => OrderItem.fromJson(item)));
    }

    List<OrderPayment> payments = [];
    if (json['pagamentos'] != null) {
      payments = List<OrderPayment>.from(
          json['pagamentos'].map((payment) => OrderPayment.fromJson(payment)));
    }

    return Order(
      id: json['id'],
      clientId: json['idCliente'],
      userId: json['idUsuario'],
      totalOrder: json['totalPedido']?.toDouble() ?? 0.0,
      creationDate: json['dataCriacao'] ??
          json['creationDate'] ??
          DateTime.now().toString(),
      lastModified: json['ultimaAlteracao'] ?? json['lastModified'],
      items: items,
      payments: payments,
      clientName: json['name'],
      orderDate: '',
      total: json['totalPedido']?.toDouble() ?? 0.0,
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'idCliente': clientId,
      'idUsuario': userId,
      'totalPedido': totalOrder,
      'dataCriacao': creationDate,
      'ultimaAlteracao': lastModified,
      'itens': items.map((item) => item.toJson()).toList(),
      'pagamentos': payments.map((payment) => payment.toJson()).toList(),
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'clientId': clientId,
      'userId': userId,
      'totalOrder': totalOrder,
      'creationDate': creationDate,
      'lastModified': lastModified,
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      clientId: map['clientId'],
      userId: map['userId'],
      totalOrder: map['totalOrder'],
      creationDate: map['creationDate'],
      lastModified: map['lastModified'],
      clientName: '',
      orderDate: '',
      total: 0,
      status: 0,
    );
  }

  get orderDate => null;

  double? get total => null;

  int? get status => null;

  get notes => null;

  get clientName => null;
}
