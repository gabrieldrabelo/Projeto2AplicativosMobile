import '../database/database_helper.dart';
import '../database/database_helper.dart';
import '../models/configuration.dart';
import '../utils/logger.dart';

class ConfigurationController {
  final dbHelper = DatabaseHelper.instance;

  Future<Configuration?> getConfiguration() async {
    final maps = await dbHelper.query('configuration');
    if (maps.isNotEmpty) {
      return Configuration.fromMap(maps.first);
    }
    return null;
  }

  Future<int> saveConfiguration(Configuration configuration) async {
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
  
  Future<int> updateLastSync(String lastSync) async {
    final existingConfig = await getConfiguration();
    
    if (existingConfig != null) {
      existingConfig.lastSync = lastSync;
      return await dbHelper.update(
        'configuration',
        existingConfig.toMap(),
        'id = ?',
        [existingConfig.id!],
      );
    } else {
      // If no configuration exists, create one with default server URL
      final config = Configuration(
        serverUrl: 'https://example.com/api',
        lastSync: lastSync,
      );
      return await dbHelper.insert('configuration', config.toMap());
    }
  }
}