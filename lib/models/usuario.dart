class Usuario {
  final String id;
  final String senha;
  final String nome;

  Usuario({
    required this.id,
    required this.senha,
    required this.nome,
  });

  factory Usuario.fromJson(Map<String, dynamic> json) {
    return Usuario(
      id: json['id'],
      senha: json['senha'],
      nome: json['nome'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senha': senha,
      'nome': nome,
    };
  }

  Usuario copyWith({
    String? id,
    String? senha,
    String? nome,
  }) {
    return Usuario(
      id: id ?? this.id,
      senha: senha ?? this.senha,
      nome: nome ?? this.nome,
    );
  }
}