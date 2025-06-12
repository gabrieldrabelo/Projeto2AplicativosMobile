import '../models/product.dart';
import '../utils/file_utils.dart';
import '../utils/logger.dart';

class ProdutoController {
  static const String _fileName = 'produtos';
  
  // Buscar todos os produtos
  Future<List<Product>> getAll() async {
    final jsonList = await FileUtils.readJsonFile(_fileName);
    return jsonList.map((json) => Product.fromJson(json)).toList();
  }
  
  // Buscar produto por ID
  Future<Product?> getById(int id) async {
    final produtos = await getAll();
    try {
      return produtos.firstWhere((produto) => produto.id == id);
    } catch (e) {
      return null;
    }
  }
  
  // Adicionar um novo produto
  Future<bool> add(Product produto) async {
    try {
      final produtos = await getAll();
      
      // Gerar ID se nu00e3o fornecido
      if (produto.id == null) {
        int maxId = 0;
        for (var p in produtos) {
          if (p.id != null && p.id! > maxId) {
            maxId = p.id!;
          }
        }
        produto.id = maxId + 1;
      }
      
      // Verificar se ju00e1 existe um produto com o mesmo ID
      if (produtos.any((p) => p.id == produto.id)) {
        return false;
      }
      
      produtos.add(produto);
      await FileUtils.writeJsonFile(_fileName, produtos.map((p) => p.toJson()).toList());
      return true;
    } catch (e) {
      Logger.e('Erro ao adicionar produto: $e');
      return false;
    }
  }
  
  // Atualizar um produto existente
  Future<bool> update(Product produto) async {
    try {
      final produtos = await getAll();
      final index = produtos.indexWhere((p) => p.id == produto.id);
      
      if (index == -1) {
        return false;
      }
      
      produtos[index] = produto;
      await FileUtils.writeJsonFile(_fileName, produtos.map((p) => p.toJson()).toList());
      return true;
    } catch (e) {
      Logger.e('Erro ao atualizar produto: $e');
      return false;
    }
  }
  
  // Remover um produto
  Future<bool> delete(int id) async {
    try {
      final produtos = await getAll();
      final initialLength = produtos.length;
      
      produtos.removeWhere((p) => p.id == id);
      
      if (produtos.length == initialLength) {
        return false;
      }
      
      await FileUtils.writeJsonFile(_fileName, produtos.map((p) => p.toJson()).toList());
      return true;
    } catch (e) {
      Logger.e('Erro ao remover produto: $e');
      return false;
    }
  }
  
  // Buscar produtos por nome
  Future<List<Product>> searchByName(String name) async {
    final produtos = await getAll();
    final searchTerm = name.toLowerCase();
    return produtos.where((p) => p.name.toLowerCase().contains(searchTerm)).toList();
  }
  
  // Buscar produtos por cu00f3digo
  Future<List<Product>> searchByCode(String code) async {
    final produtos = await getAll();
    final searchTerm = code.toLowerCase();
    return produtos.where((p) => p.code.toLowerCase().contains(searchTerm)).toList();
  }
  
  // Atualizar estoque do produto
  Future<bool> updateStock(int id, double quantity) async {
    try {
      final produto = await getById(id);
      if (produto == null) {
        return false;
      }
      
      produto.stock = quantity;
      return await update(produto);
    } catch (e) {
      Logger.e('Erro ao atualizar estoque: $e');
      return false;
    }
  }
}