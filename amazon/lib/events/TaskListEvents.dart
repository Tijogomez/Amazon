import 'package:amazon/util/TaskStatus.dart';

abstract class TaskListEvents {}

class OnRefresh extends TaskListEvents {}

class OnStatusFilterSelect extends TaskListEvents {
  final TaskStatus status;
  OnStatusFilterSelect({required this.status});
}

class OnCreatedDateFilterSelect extends TaskListEvents {
  final DateTime date;
  OnCreatedDateFilterSelect({required this.date});
}

class OnCompleteByDateFilterSelect extends TaskListEvents {
  final DateTime date;
  OnCompleteByDateFilterSelect({required this.date});
}
