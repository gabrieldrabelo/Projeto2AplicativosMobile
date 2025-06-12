import 'dart:convert';
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'logger.dart';

class FileUtils {
  /// Retorna o diretório de documentos da aplicação
  static Future<Directory> get _documentsDirectory async {
    return await getApplicationDocumentsDirectory();
  }

  /// Retorna o caminho completo para um arquivo
  static Future<String> _getFilePath(String fileName) async {
    final dir = await _documentsDirectory;
    return '${dir.path}/$fileName.json';
  }

  /// Lê um arquivo JSON e retorna seu conteúdo como List<dynamic>
  static Future<List<dynamic>> readJsonFile(String fileName) async {
    try {
      final filePath = await _getFilePath(fileName);
      final file = File(filePath);
      
      // Se o arquivo não existir, retorna uma lista vazia
      if (!file.existsSync()) {
        return [];
      }
      
      final jsonString = await file.readAsString();
      return jsonDecode(jsonString) as List<dynamic>;
    } catch (e) {
      Logger.e('Erro ao ler arquivo JSON: $e');
      return [];
    }
  }

  /// Escreve uma lista de objetos em um arquivo JSON
  static Future<bool> writeJsonFile(String fileName, List<dynamic> data) async {
    try {
      final filePath = await _getFilePath(fileName);
      final file = File(filePath);
      
      // Cria o diretório se não existir
      if (!file.parent.existsSync()) {
        file.parent.createSync(recursive: true);
      }
      
      final jsonString = jsonEncode(data);
      await file.writeAsString(jsonString);
      return true;
    } catch (e) {
      Logger.e('Erro ao escrever arquivo JSON: $e');
      return false;
    }
  }

  /// Verifica se um arquivo existe
  static Future<bool> fileExists(String fileName) async {
    try {
      final filePath = await _getFilePath(fileName);
      final file = File(filePath);
      return file.existsSync();
    } catch (e) {
      Logger.e('Erro ao verificar existência do arquivo: $e');
      return false;
    }
  }

  /// Deleta um arquivo
  static Future<bool> deleteFile(String fileName) async {
    try {
      final filePath = await _getFilePath(fileName);
      final file = File(filePath);
      
      if (file.existsSync()) {
        await file.delete();
        return true;
      }
      return false;
    } catch (e) {
      Logger.e('Erro ao deletar arquivo: $e');
      return false;
    }
  }
}