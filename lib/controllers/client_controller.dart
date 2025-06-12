import 'dart:convert';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/client.dart';
import '../utils/logger.dart';

class ClientController {
  final dbHelper = DatabaseHelper.instance;

  Future<List<Client>> getClients() async {
    final maps = await dbHelper.query('clients');
    return List.generate(maps.length, (i) => Client.fromMap(maps[i]));
  }

  Future<Client?> getClientById(int id) async {
    final maps = await dbHelper.query('clients', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return Client.fromMap(maps.first);
    }
    return null;
  }

  Future<int> addClient(Client client) async {
    return await dbHelper.insert('clients', client.toMap());
  }

  Future<int> updateClient(Client client) async {
    // Update lastModified timestamp
    client.lastModified = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    
    return await dbHelper.update(
      'clients',
      client.toMap(),
      'id = ?',
      [client.id!],
    );
  }

  Future<int> deleteClient(int id) async {
    return await dbHelper.delete('clients', 'id = ?', [id]);
  }

  // Method to search address by ZIP code using ViaCEP API
  Future<Map<String, dynamic>?> searchAddressByZipCode(String zipCode) async {
    try {
      final response = await http.get(Uri.parse('https://viacep.com.br/ws/$zipCode/json/'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Check if the API returned an error
        if (data.containsKey('erro') && data['erro'] == true) {
          return null;
        }
        
        return {
          'address': data['logradouro'],
          'neighborhood': data['bairro'],
          'city': data['localidade'],
          'state': data['uf'],
        };
      }
      return null;
    } catch (e) {
      print('Error searching ZIP code: $e');
      return null;
    }
  }
}