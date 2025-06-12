class Configuration {
class Configuration {
  int? id;
  String serverUrl;
  String? lastSync;

  Configuration({
    this.id,
    required this.serverUrl,
    this.lastSync,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serverUrl': serverUrl,
      'lastSync': lastSync,
    };
  }

  factory Configuration.fromMap(Map<String, dynamic> map) {
    return Configuration(
      id: map['id'],
      serverUrl: map['serverUrl'],
      lastSync: map['lastSync'],
    );
  }
}