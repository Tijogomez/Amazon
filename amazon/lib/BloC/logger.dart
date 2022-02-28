import 'package:amazon/db/Tasks.dart';
import 'package:amazon/db/TasksDataSource.dart';
import 'package:amazon/db/UserDataSource.dart';
import 'package:amazon/db/database.dart';
import 'package:amazon/db/log.dart';
import 'package:amazon/util/TaskStatus.dart';
import 'package:sqflite/sqlite_api.dart';

class Logger {
  Future<List<Log>> getLogs(int page) async {
    final Database db = await AmazonDatabase.instance.database;
    final result = await db.rawQuery('''
    SELECT *
    FROM $LogTableName LIMIT $PAGE_SIZE
    OFFSET ?
    ''', [page * PAGE_SIZE]);
    return result.map((e) => Log.fromJson(e)).toList();
  }

  Future logEvent(TaskStatus event, String name) async {
    final Database db = await AmazonDatabase.instance.database;
    final log = Log(
        username: UserDataSource.loggedInUser!.username,
        event: event,
        date: DateTime.now().millisecondsSinceEpoch,
        name: name);

    db.insert(LogTableName, log.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }
}

const int PAGE_SIZE = 8;
