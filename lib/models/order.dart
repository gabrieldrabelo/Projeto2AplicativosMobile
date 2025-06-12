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
  String? clientName; // Nome do cliente para exibição
  String? notes; // Observações do pedido
  String status; // Status do pedido: 'draft', 'confirmed', 'delivered', 'canceled'

  Order({
    this.id,
    required this.clientId,
    required this.userId,
    required this.totalOrder,
    required this.creationDate,
    this.lastModified,
    this.items = const [],
    this.payments = const [],
    this.clientName,
    this.notes,
    this.status = 'draft',
  });

  // Getter para o total do pedido (calculado a partir dos itens)
  double get total {
    double total = 0;
    for (var item in items) {
      total += item.totalItem;
    }
    return total;
  }

  // Getter para a data do pedido formatada
  String get orderDate => creationDate;

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
      creationDate: json['dataCriacao'] ?? json['creationDate'] ?? DateTime.now().toString(),
      lastModified: json['ultimaAlteracao'] ?? json['lastModified'],
      items: items,
      payments: payments,
      clientName: json['clientName'],
      notes: json['notes'],
      status: json['status'] ?? 'draft',
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
      'clientName': clientName,
      'notes': notes,
      'status': status,
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
      'notes': notes,
      'status': status,
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
      notes: map['notes'],
      status: map['status'] ?? 'draft',
    );
  }
}