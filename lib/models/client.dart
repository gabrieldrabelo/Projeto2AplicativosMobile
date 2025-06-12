class Client {
class Client {
  int? id;
  String name;
  String type; // F - Physical / J - Legal
  String cpfCnpj;
  String? email;
  String? phone;
  String? zipCode;
  String? address;
  String? neighborhood;
  String? city;
  String? state;
  String? lastModified;

  Client({
    this.id,
    required this.name,
    required this.type,
    required this.cpfCnpj,
    this.email,
    this.phone,
    this.zipCode,
    this.address,
    this.neighborhood,
    this.city,
    this.state,
    this.lastModified,
  });

  factory Client.fromJson(Map<String, dynamic> json) {
    return Client(
      id: json['id'],
      name: json['name'],
      type: json['type'],
      cpfCnpj: json['cpfCnpj'],
      email: json['email'],
      phone: json['telefone'] ?? json['phone'],
      zipCode: json['cep'] ?? json['zipCode'],
      address: json['endereco'] ?? json['address'],
      neighborhood: json['bairro'] ?? json['neighborhood'],
      city: json['cidade'] ?? json['city'],
      state: json['uf'] ?? json['state'],
      lastModified: json['ultimaAlteracao'] ?? json['lastModified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'cpfCnpj': cpfCnpj,
      'email': email,
      'telefone': phone,
      'cep': zipCode,
      'endereco': address,
      'bairro': neighborhood,
      'cidade': city,
      'uf': state,
      'ultimaAlteracao': lastModified,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'cpfCnpj': cpfCnpj,
      'email': email,
      'phone': phone,
      'zipCode': zipCode,
      'address': address,
      'neighborhood': neighborhood,
      'city': city,
      'state': state,
      'lastModified': lastModified,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      type: map['type'],
      cpfCnpj: map['cpfCnpj'],
      email: map['email'],
      phone: map['phone'],
      zipCode: map['zipCode'],
      address: map['address'],
      neighborhood: map['neighborhood'],
      city: map['city'],
      state: map['state'],
      lastModified: map['lastModified'],
    );
  }
}