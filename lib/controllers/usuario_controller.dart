import '../models/usuario.dart';
import '../utils/file_utils.dart';
import '../utils/logger.dart';

class UsuarioController {
  static const String _fileName = 'usuarios';
  
  // Buscar todos os usuu00e1rios
  Future<List<Usuario>> getAll() async {
    final jsonList = await FileUtils.readJsonFile(_fileName);
    return jsonList.map((json) => Usuario.fromJson(json)).toList();
  }
  
  // Buscar usuu00e1rio por ID
  Future<Usuario?> getById(String id) async {
    final usuarios = await getAll();
    try {
      return usuarios.firstWhere((usuario) => usuario.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Adicionar um novo usuu00e1rio
  Future<bool> add(Usuario usuario) async {
    try {
      final usuarios = await getAll();
      
      // Verificar se ju00e1 existe um usuu00e1rio com o mesmo ID
      if (usuarios.any((u) => u.id == usuario.id)) {
        return false;
      }
      
      usuarios.add(usuario);
      await FileUtils.writeJsonFile(_fileName, usuarios.map((u) => u.toJson()).toList());
      return true;
    } catch (e) {
      Logger.e('Erro ao adicionar usuu00e1rio: $e');
      return false;
    }
  }
  
  // Atualizar um usuu00e1rio existente
  Future<bool> update(Usuario usuario) async {
    try {
      final usuarios = await getAll();
      final index = usuarios.indexWhere((u) => u.id == usuario.id);
      
      if (index == -1) {
        return false;
      }
      
      usuarios[index] = usuario;
      await FileUtils.writeJsonFile(_fileName, usuarios.map((u) => u.toJson()).toList());
      return true;
    } catch (e) {
      Logger.e('Erro ao atualizar usuu00e1rio: $e');
      return false;
    }
  }
  
  // Remover um usuu00e1rio
  Future<bool> delete(String id) async {
    try {
      final usuarios = await getAll();
      final initialLength = usuarios.length;
      
      usuarios.removeWhere((u) => u.id == id);
      
      if (usuarios.length == initialLength) {
        return false;
      }
      
      await FileUtils.writeJsonFile(_fileName, usuarios.map((u) => u.toJson()).toList());
      return true;
    } catch (e) {
      Logger.e('Erro ao remover usuu00e1rio: $e');
      return false;
    }
  }
  
  // Validar login
  Future<bool> validarLogin(String id, String senha) async {
    try {
      final usuarios = await getAll();
      
      // Se nu00e3o houver usuu00e1rios cadastrados, permitir acesso com admin/admin
      if (usuarios.isEmpty && id == 'admin' && senha == 'admin') {
        return true;
      }
      
      return usuarios.any((u) => u.id == id && u.senha == senha);
    } catch (e) {
      Logger.e('Erro ao validar login: $e');
      return false;
    }
  }
}