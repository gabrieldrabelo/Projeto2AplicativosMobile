class PaymentType {
  final String id;
  final String name;
  final String? icon;
  
  const PaymentType({
    required this.id,
    required this.name,
    this.icon,
  });
  
  // Lista de tipos de pagamento padru00e3o
  static const List<PaymentType> defaultTypes = [
    PaymentType(
      id: 'cash',
      name: 'Dinheiro',
      icon: 'assets/icons/cash.png',
    ),
    PaymentType(
      id: 'credit_card',
      name: 'Cartu00e3o de Cru00e9dito',
      icon: 'assets/icons/credit_card.png',
    ),
    PaymentType(
      id: 'debit_card',
      name: 'Cartu00e3o de Du00e9bito',
      icon: 'assets/icons/debit_card.png',
    ),
    PaymentType(
      id: 'pix',
      name: 'PIX',
      icon: 'assets/icons/pix.png',
    ),
    PaymentType(
      id: 'bank_transfer',
      name: 'Transferu00eancia Bancu00e1ria',
      icon: 'assets/icons/bank_transfer.png',
    ),
    PaymentType(
      id: 'check',
      name: 'Cheque',
      icon: 'assets/icons/check.png',
    ),
    PaymentType(
      id: 'other',
      name: 'Outro',
      icon: 'assets/icons/other.png',
    ),
  ];
  
  // Mu00e9todo para obter um tipo de pagamento pelo ID
  static PaymentType getById(String id) {
    return defaultTypes.firstWhere(
      (type) => type.id == id,
      orElse: () => defaultTypes.last, // Retorna 'Outro' se nu00e3o encontrar
    );
  }
  
  // Mu00e9todo para obter um tipo de pagamento pelo nome
  static PaymentType getByName(String name) {
    return defaultTypes.firstWhere(
      (type) => type.name == name,
      orElse: () => defaultTypes.last, // Retorna 'Outro' se nu00e3o encontrar
    );
  }
}