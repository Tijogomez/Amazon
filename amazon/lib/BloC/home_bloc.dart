import 'dart:async';
import 'package:amazon/BloC/bloc.dart';
import 'package:amazon/db/Tasks.dart';
import 'package:amazon/db/TasksDataSource.dart';
import 'package:amazon/events/TaskListEvents.dart';
import 'package:amazon/util/TaskStatus.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class HomeBloc implements Bloc {
  final TasksDataSource _dataSource = TasksDataSource();

  //Tasks List
  final _tasksController = StreamController<List<Tasks>>();
  Stream<List<Tasks>> get tasks => _tasksController.stream;

  // Events Controller
  final _eventsController = StreamController<TaskListEvents>();
  Sink<TaskListEvents> get eventSink => _eventsController.sink;

  // Init State
  void initState() {
    _getTasks();
  }

  HomeBloc() {
    _eventsController.stream.listen((event) {
      if (event is OnRefresh) {
        _getTasks();
      } else if (event is OnStatusFilterSelect) {
        _filterTasksByStatus(event.status);
      } else if (event is OnCreatedDateFilterSelect) {
        _filterTasksByCreatedDate(event.date);
      } else if (event is OnCompleteByDateFilterSelect) {
        _filterTasksByCompleteByDate(event.date);
      }
    });
  }

  void _filterTasksByStatus(TaskStatus status) async {
    _tasksController.sink.add(await _dataSource.getTasksByStatus(status));
  }

  void _filterTasksByCreatedDate(DateTime date) async {
    final _result = await _dataSource.getTasks();
    final _dateFormat = DateFormat("dd-MM-yyyy");
    _tasksController.sink.add(_result
        .where((element) =>
            _dateFormat.format(
                DateTime.fromMillisecondsSinceEpoch(element.createdDate)) ==
            _dateFormat.format(date))
        .toList());
  }

  void _filterTasksByCompleteByDate(DateTime date) async {
    final _result = await _dataSource.getTasks();
    final _dateFormat = DateFormat("dd-MM-yyyy");
    _tasksController.sink.add(_result
        .where((element) =>
            _dateFormat.format(DateTime.fromMillisecondsSinceEpoch(
                element.completeBeforeDate)) ==
            _dateFormat.format(date))
        .toList());
  }

  MaterialColor getColorForStatus(TaskStatus status) {
    switch (status) {
      case TaskStatus.PENDING:
        return Colors.red;
      case TaskStatus.COMPLETED:
        return Colors.green;
      case TaskStatus.STARTED:
        return Colors.yellow;
      case TaskStatus.PAUSED:
        return Colors.grey;
    }
  }

  // Get Task List
  void _getTasks() async {
    final _result = await _dataSource.getTasks();
    _tasksController.sink.add(_result);
  }

  @override
  void dispose() {
    _tasksController.close();
  }
}
