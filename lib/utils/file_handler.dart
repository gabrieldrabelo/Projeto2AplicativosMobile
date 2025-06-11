import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class FileHandler {
  static Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  static Future<File> _localFile(String fileName) async {
    final path = await _localPath;
    return File('$path/$fileName.json');
  }

  static Future<void> writeData(String fileName, List<dynamic> data) async {
    try {
      final file = await _localFile(fileName);
      await file.writeAsString(jsonEncode(data));
    } catch (e) {
      print('Error writing to file: $e');
    }
  }

  static Future<List<dynamic>> readData(String fileName) async {
    try {
      final file = await _localFile(fileName);
      if (!await file.exists()) {
        return [];
      }
      final contents = await file.readAsString();
      return jsonDecode(contents);
    } catch (e) {
      print('Error reading file: $e');
      return [];
    }
  }
}