import 'package:amazon/db/Tasks.dart';
import 'package:amazon/db/database.dart';
import 'package:amazon/util/TaskStatus.dart';
import 'package:sqflite/sqflite.dart';

class TasksDataSource {
  Future<List<Tasks>> getTasks() async {
    final Database db = await AmazonDatabase.instance.database;

    final result = await db.query(
      TasksTableName,
      columns: TasksColumns,
    );
    return result.map((tasksEntitiy) => Tasks.fromJson(tasksEntitiy)).toList();
  }

  Future<List<Tasks>> getTasksByStatus(TaskStatus status) async {
    final Database db = await AmazonDatabase.instance.database;

    final result = await db.query(TasksTableName,
        columns: TasksColumns, where: 'status = ?', whereArgs: [status.name]);
    return result.map((tasksEntitiy) => Tasks.fromJson(tasksEntitiy)).toList();
  }

  Future<List<Tasks>> getTasksByCreatedDate(int date) async {
    final Database db = await AmazonDatabase.instance.database;

    final result = await db.query(TasksTableName,
        columns: TasksColumns, where: 'createdDate = ?', whereArgs: [date]);
    return result.map((tasksEntitiy) => Tasks.fromJson(tasksEntitiy)).toList();
  }

  Future<List<Tasks>> getTasksByCompletedDate(int date) async {
    final Database db = await AmazonDatabase.instance.database;

    final result = await db.query(TasksTableName,
        columns: TasksColumns,
        where: 'completeBeforeDate = ?',
        whereArgs: [date]);
    return result.map((tasksEntitiy) => Tasks.fromJson(tasksEntitiy)).toList();
  }

  Future<Tasks?> getTaskById(int taskId) async {
    final Database db = await AmazonDatabase.instance.database;

    final result = await db.query(TasksTableName,
        columns: TasksColumns, where: 'id = ?', whereArgs: [taskId]);

    final task = result
        .map((tasksEntitiy) => Tasks.fromJson(tasksEntitiy))
        .toList()
        .first;
    return task;
  }

  Future addTask(Tasks task) async {
    final Database db = await AmazonDatabase.instance.database;
    db.insert(TasksTableName, task.toJson(task.id == -1),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future deleteAll() async {
    final db = await AmazonDatabase.instance.database;

    await db.rawDelete("DELETE FROM $TasksTableName");
  }
}
