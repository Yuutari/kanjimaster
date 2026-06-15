import '../models/user_model.dart';
import 'database_provider.dart';

class UsersRepository {
  final DatabaseProvider db;

  UsersRepository(this.db);

  Future<UserModel?> getUserById(int id) async {
    final items = db.usersTable.where((item) => item.id == id).toList();
    return items.isEmpty ? null : items.first;
  }

  Future<void> saveUser(UserModel user) async {
    final index = db.usersTable.indexWhere((item) => item.id == user.id);
    if (index >= 0) {
      db.usersTable[index] = user;
    } else {
      db.usersTable.add(user);
    }
  }
}
