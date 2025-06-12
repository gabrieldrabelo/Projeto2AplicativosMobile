class OrderStatus {
  final String id;
  final String name;
  final String color; // Cor em formato hexadecimal
  
  const OrderStatus({
    required this.id,
    required this.name,
    required this.color,
  });
  
  // Lista de status de pedido padru00e3o
  static const List<OrderStatus> defaultStatuses = [
    OrderStatus(
      id: 'draft',
      name: 'Rascunho',
      color: '#9E9E9E', // Cinza
    ),
    OrderStatus(
      id: 'confirmed',
      name: 'Confirmado',
      color: '#2196F3', // Azul
    ),
    OrderStatus(
      id: 'in_progress',
      name: 'Em Andamento',
      color: '#FF9800', // Laranja
    ),
    OrderStatus(
      id: 'delivered',
      name: 'Entregue',
      color: '#4CAF50', // Verde
    ),
    OrderStatus(
      id: 'canceled',
      name: 'Cancelado',
      color: '#F44336', // Vermelho
    ),
    OrderStatus(
      id: 'pending_payment',
      name: 'Aguardando Pagamento',
      color: '#FFC107', // Amarelo
    ),
  ];
  
  // Mu00e9todo para obter um status pelo ID
  static OrderStatus getById(String id) {
    return defaultStatuses.firstWhere(
      (status) => status.id == id,
      orElse: () => defaultStatuses[0], // Retorna 'Rascunho' se nu00e3o encontrar
    );
  }
  
  // Mu00e9todo para obter um status pelo nome
  static OrderStatus getByName(String name) {
    return defaultStatuses.firstWhere(
      (status) => status.name == name,
      orElse: () => defaultStatuses[0], // Retorna 'Rascunho' se nu00e3o encontrar
    );
  }
}