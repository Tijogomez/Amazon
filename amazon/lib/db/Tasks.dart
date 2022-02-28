import 'package:amazon/util/TaskStatus.dart';
import 'dart:convert';

class Tasks {
  final int id;
  final String name;
  final TaskStatus status;
  final int createdDate;
  final List<String> images;
  final int pin;
  final int completeBeforeDate;

  const Tasks(
      {required this.name,
      this.status = TaskStatus.PENDING,
      this.id = -1,
      required this.createdDate,
      required this.completeBeforeDate,
      this.images = const [],
      required this.pin});

  Map<String, Object?> toJson(bool isNew) {
    if (isNew) {
      return {
        'name': name,
        'status': status.name,
        'createdDate': createdDate,
        'completeBeforeDate': completeBeforeDate,
        'images': json.encode(images),
        'pin': pin
      };
    } else {
      return {
        'id': id,
        'name': name,
        'status': status.name,
        'createdDate': createdDate,
        'completeBeforeDate': completeBeforeDate,
        'images': json.encode(images),
        'pin': pin
      };
    }
  }

  static Tasks fromJson(Map<String, Object?> jsonObj) => Tasks(
      id: jsonObj['id'] as int,
      name: jsonObj['name'] as String,
      status: TaskStatus.values.byName(jsonObj['status'] as String),
      createdDate: jsonObj['createdDate'] as int,
      completeBeforeDate: jsonObj['completeBeforeDate'] as int,
      pin: jsonObj['pin'] as int,
      images: (json.decode(jsonObj['images'] as String) as List)
          .map((e) => e as String)
          .toList());

  Tasks copy(
          {String? name,
          TaskStatus? status,
          int? completeBeforeDate,
          List<String>? images}) =>
      Tasks(
          id: id,
          name: name ?? this.name,
          status: status ?? this.status,
          createdDate: createdDate,
          completeBeforeDate: completeBeforeDate ?? this.completeBeforeDate,
          images: images ?? this.images,
          pin: pin);
}

const List<String> TasksColumns = [
  'id',
  'name',
  'status',
  'createdDate',
  'completeBeforeDate',
  'pin',
  'images'
];

const TasksTableName = "Tasks";
