import 'dart:async';
import 'dart:math';

import 'package:amazon/BloC/bloc.dart';
import 'package:amazon/BloC/logger.dart';
import 'package:amazon/db/Tasks.dart';
import 'package:amazon/db/TasksDataSource.dart';
import 'package:amazon/db/log.dart';
import 'package:amazon/events/AddEditTaskEvents.dart';
import 'package:amazon/util/TaskStatus.dart';

class AddEditTaskBloc extends Bloc {
  final _dataSource = TasksDataSource();

  final _logger = Logger();

  bool _hasStatusChanged = false;

  // Events Controller
  final StreamController<AddEditTaskEvents> _eventsController =
      StreamController();
  Sink<AddEditTaskEvents> get eventsSink => _eventsController.sink;

  // Task Controller
  final StreamController<Tasks> _taskController = StreamController();
  Stream<Tasks> get taskStream => _taskController.stream;

  void initState(int taskId) async {
    final bool isNewTask = taskId == -1;
    if (isNewTask) {
      final defaultTask = Tasks(
        name: "",
        pin: int.parse(generatePassword()),
        createdDate: DateTime.now().millisecondsSinceEpoch,
        completeBeforeDate: DateTime.now().millisecondsSinceEpoch,
        images: [],
        description: "",
      );

      _taskController.sink.add(defaultTask);
    } else {
      final task = await _dataSource.getTaskById(taskId);
      if (task != null) {
        _taskController.sink.add(task);
      }
    }
  }

  List<TaskStatus> getPossibleTargetStatuses(TaskStatus status) {
    List<TaskStatus> _targetStatuses = [status];
    switch (status) {
      case TaskStatus.PENDING:
        _targetStatuses.add(TaskStatus.STARTED);
        break;
      case TaskStatus.COMPLETED:
        break;
      case TaskStatus.STARTED:
        _targetStatuses.addAll([TaskStatus.PAUSED, TaskStatus.COMPLETED]);
        break;
      case TaskStatus.PAUSED:
        _targetStatuses.add(TaskStatus.STARTED);
        break;
    }

    return _targetStatuses;
  }

  void _onEvent(AddEditTaskEvents event) {
    if (event is OnTaskNameChange) {
      _taskController.sink.add(event.task);
    } else if (event is OnTaskSubmit) {
      _dataSource.addTask(event.task!);
      _logEvent(event.task!.status, event.task!.name);
    } else if (event is OnTaskStatusChange) {
      _taskController.sink.add(event.task);
      _hasStatusChanged = true;
    } else if (event is OnCompleteBeforeDateChange) {
      _taskController.sink.add(event.task);
    } else if (event is OnImageSelect) {
      _taskController.sink.add(event.task!);
    } else if (event is OnDescriptionChange) {
      _taskController.sink.add(event.task!);
    }
  }

  void _logEvent(TaskStatus event, String name) async {
    _logger.logEvent(event, name);
  }

  AddEditTaskBloc() {
    _eventsController.stream.listen((event) {
      _onEvent(event);
    });
  }

  @override
  void dispose() {
    _eventsController.close();
    _taskController.close();
  }

  String generatePassword() {
    final length = 3;
    final numbers = '0123456789';

    String num = '';
    num += '$numbers';

    return List.generate(length, (index) {
      final indexRandom = Random().nextInt(num.length);

      return num[indexRandom];
    }).join();
  }
}
