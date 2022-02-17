import 'package:amazon/util/TaskStatus.dart';

class Tasks {
  final int id;
  final String name;
  final TaskStatus status;
  final int createdDate;
  final int pin;
  final int completeBeforeDate;

  const Tasks(
      {required this.name,
      this.status = TaskStatus.PENDING,
      this.id = -1,
      required this.createdDate,
      required this.completeBeforeDate,
      required this.pin});

  Map<String, Object?> toJson(bool isNew) {
    if (isNew) {
      return {
        'name': name,
        'status': status.name,
        'createdDate': createdDate,
        'completeBeforeDate': completeBeforeDate,
        'pin': pin
      };
    } else {
      return {
        'id': id,
        'name': name,
        'status': status.name,
        'createdDate': createdDate,
        'completeBeforeDate': completeBeforeDate,
        'pin': pin
      };
    }
  }

  static Tasks fromJson(Map<String, Object?> json) => Tasks(
      id: json['id'] as int,
      name: json['name'] as String,
      status: TaskStatus.values.byName(json['status'] as String),
      createdDate: json['createdDate'] as int,
      completeBeforeDate: json['completeBeforeDate'] as int,
      pin: json['pin'] as int);

  Tasks copy({String? name, TaskStatus? status, int? completeBeforeDate}) =>
      Tasks(
          id: id,
          name: name ?? this.name,
          status: status ?? this.status,
          createdDate: createdDate,
          completeBeforeDate: completeBeforeDate ?? this.completeBeforeDate,
          pin: pin);
}

const List<String> TasksColumns = [
  'id',
  'name',
  'status',
  'createdDate',
  'completeBeforeDate',
  'pin'
];

const TasksTableName = "Tasks";
