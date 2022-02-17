import 'package:amazon/db/Tasks.dart';

abstract class AddEditTaskEvents {}

class OnTaskNameChange extends AddEditTaskEvents {
  Tasks task;
  OnTaskNameChange({required this.task});
}

class OnTaskStatusChange extends AddEditTaskEvents {
  Tasks task;
  OnTaskStatusChange({required this.task});
}

class OnCompleteBeforeDateChange extends AddEditTaskEvents {
  Tasks task;
  OnCompleteBeforeDateChange({required this.task});
}

class OnTaskSubmit extends AddEditTaskEvents {
  Tasks? task;
  OnTaskSubmit(this.task);
}
