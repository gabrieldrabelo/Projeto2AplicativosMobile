import 'package:intl/intl.dart';
import '../database/database_helper.dart';
import '../models/user.dart';

class UserController {
  final dbHelper = DatabaseHelper.instance;

  Future<List<User>> getUsers() async {
    final maps = await dbHelper.query('users');
    return List.generate(maps.length, (i) => User.fromMap(maps[i]));
  }

  Future<User?> getUserById(int id) async {
    final maps = await dbHelper.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  Future<bool> validateUser(String username, String password) async {
    final maps = await dbHelper.query(
      'users',
      where: 'name = ? AND password = ?',
      whereArgs: [username, password],
    );
    return maps.isNotEmpty;
  }

  Future<int> addUser(User user) async {
    return await dbHelper.insert('users', user.toMap());
  }

  Future<int> updateUser(User user) async {
    // Update lastModified timestamp
    user.lastModified = DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());
    
    return await dbHelper.update(
      'users',
      user.toMap(),
      'id = ?',
      [user.id!],
    );
  }

  Future<int> deleteUser(int id) async {
    return await dbHelper.delete('users', 'id = ?', [id]);
  }
}