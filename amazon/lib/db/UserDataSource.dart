import 'package:amazon/db/database.dart';
import 'package:sqflite/sqflite.dart';

import 'User.dart';

class UserDataSource {
  static User? loggedInUser;

  Future createUser(String username, String password, String? email) async {
    final Database db = await AmazonDatabase.instance.database;

    final user = User(username: username, password: password, email: email);

    await db.insert(UserTableName, user.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<bool> authenticate(String username, String password) async {
    final Database db = await AmazonDatabase.instance.database;

    final result = await db.query(UserTableName,
        columns: UserColumns,
        where: 'username = ? AND password = ?',
        whereArgs: [username, password]);

    if (result.isNotEmpty) {
      loggedInUser = User.fromJson(result[0]);
      return true;
    } else {
      return false;
    }
  }

  Future<bool> updateUserPassword(String username, String newPassword) async {
    final Database db = await AmazonDatabase.instance.database;

    try {
      await db.rawUpdate(
          "UPDATE $UserTableName SET password = ? WHERE username = ?",
          [newPassword, username]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<User?> loginUser(String username) async {
    final Database db = await AmazonDatabase.instance.database;

    final result = await db.query(UserTableName,
        columns: UserColumns,
        limit: 1,
        where: 'username=?',
        whereArgs: [username]);
    if (result.isNotEmpty) {
      loggedInUser = User.fromJson(result[0]);
    }
    return loggedInUser;
  }
}
