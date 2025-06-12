
class User {
  int? id;
  String name;
  String password;
  String? lastModified;

  User({
    this.id,
    required this.name,
    required this.password,
    this.lastModified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      password: json['password'],
      lastModified: json['ultimaAlteracao'] ?? json['lastModified'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'ultimaAlteracao': lastModified,
    };
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'password': password,
      'lastModified': lastModified,
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      name: map['name'],
      password: map['password'],
      lastModified: map['lastModified'],
    );
  }
}