import '../models/client.dart';
import '../utils/file_utils.dart';
import '../utils/logger.dart';

class ClienteController {
  static const String _fileName = 'clientes';
  
  // Buscar todos os clientes
  Future<List<Client>> getAll() async {
    final jsonList = await FileUtils.readJsonFile(_fileName);
    return jsonList.map((json) => Client.fromJson(json)).toList();
  }
  
  // Buscar cliente por ID
  Future<Client?> getById(int id) async {
    final clientes = await getAll();
    try {
      return clientes.firstWhere((cliente) => cliente.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Adicionar um novo cliente
  Future<bool> add(Client cliente) async {
    try {
      final clientes = await getAll();
      
      // Gerar ID se nu00e3o fornecido
      if (cliente.id == null) {
        int maxId = 0;
        for (var c in clientes) {
          if (c.id != null && c.id! > maxId) {
            maxId = c.id!;
          }
        }
        cliente.id = maxId + 1;
      }
      
      // Verificar se ju00e1 existe um cliente com o mesmo ID
      if (clientes.any((c) => c.id == cliente.id)) {
        return false;
      }
      
      clientes.add(cliente);
      await FileUtils.writeJsonFile(_fileName, clientes.map((c) => c.toJson()).toList());
      return true;
    } catch (e) {
      Logger.e('Erro ao adicionar cliente: $e');
      return false;
    }
  }
  
  // Atualizar um cliente existente
  Future<bool> update(Client cliente) async {
    try {
      final clientes = await getAll();
      final index = clientes.indexWhere((c) => c.id == cliente.id);
      
      if (index == -1) {
        return false;
      }
      
      clientes[index] = cliente;
      await FileUtils.writeJsonFile(_fileName, clientes.map((c) => c.toJson()).toList());
      return true;
    } catch (e) {
      Logger.e('Erro ao atualizar cliente: $e');
      return false;
    }
  }
  
  // Remover um cliente
  Future<bool> delete(int id) async {
    try {
      final clientes = await getAll();
      final initialLength = clientes.length;
      
      clientes.removeWhere((c) => c.id == id);
      
      if (clientes.length == initialLength) {
        return false;
      }
      
      await FileUtils.writeJsonFile(_fileName, clientes.map((c) => c.toJson()).toList());
      return true;
    } catch (e) {
      Logger.e('Erro ao remover cliente: $e');
      return false;
    }
  }
  
  // Buscar clientes por nome
  Future<List<Client>> searchByName(String name) async {
    final clientes = await getAll();
    final searchTerm = name.toLowerCase();
    return clientes.where((c) => c.name.toLowerCase().contains(searchTerm)).toList();
  }
  
  // Buscar clientes por CPF/CNPJ
  Future<List<Client>> searchByCpfCnpj(String cpfCnpj) async {
    final clientes = await getAll();
    final searchTerm = cpfCnpj.replaceAll(RegExp(r'[^0-9]'), '');
    return clientes.where((c) => c.cpfCnpj.replaceAll(RegExp(r'[^0-9]'), '').contains(searchTerm)).toList();
  }
}