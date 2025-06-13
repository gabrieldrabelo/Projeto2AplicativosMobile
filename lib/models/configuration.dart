class Configuration {
  int? id;
  String serverUrl;

  Configuration({
    this.id,
    required this.serverUrl,
    String? lastSync,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverUrl': serverUrl,
    };
  }

  factory Configuration.fromMap(Map<String, dynamic> map) {
    return Configuration(
      id: map['id'],
      serverUrl: map['serverUrl'],
    );
  }

  String? get lastSync => null;
}
