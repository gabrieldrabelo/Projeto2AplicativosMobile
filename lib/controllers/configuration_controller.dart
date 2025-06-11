import '../database/database_helper.dart';
import '../models/configuration.dart';

class ConfigurationController {
  final dbHelper = DatabaseHelper.instance;

  Future<Configuration?> getConfiguration() async {
    final maps = await dbHelper.query('configuration');
    if (maps.isNotEmpty) {
      return Configuration.fromMap(maps.first);
    }
    return null;
  }

  Future<int> updateConfiguration(Configuration configuration) async {
    final existingConfig = await getConfiguration();
    
    if (existingConfig != null) {
      configuration.id = existingConfig.id;
      return await dbHelper.update(
        'configuration',
        configuration.toMap(),
        'id = ?',
        [configuration.id!],
      );
    } else {
      return await dbHelper.insert('configuration', configuration.toMap());
    }
  }
}