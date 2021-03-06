import 'package:amazon/util/TaskStatus.dart';
import 'dart:convert';

import 'package:geolocator/geolocator.dart';

class Tasks {
  final int id;
  final String name;
  final TaskStatus status;
  final double latitude;
  final double longitude;
  final int createdDate;
  final List<String> images;
  final int pin;
  final int completeBeforeDate;
  final String description;

  const Tasks(
      {required this.name,
      this.status = TaskStatus.PENDING,
      this.id = -1,
      required this.createdDate,
      required this.completeBeforeDate,
      this.images = const [],
      this.latitude =0.0,
      this.longitude=0.0,
      required this.pin,
      required this.description});

  Map<String, Object?> toJson(bool isNew) {
    if (isNew) {
      return {
        'name': name,
        'status': status.name,
        'createdDate': createdDate,
        'completeBeforeDate': completeBeforeDate,
        'images': json.encode(images),
        'pin': pin,
        'description': description,
        'latitude': latitude,
        'longitude':longitude
      };
    } else {
      return {
        'id': id,
        'name': name,
        'status': status.name,
        'createdDate': createdDate,
        'completeBeforeDate': completeBeforeDate,
        'images': json.encode(images),
        'pin': pin,
        'description': description,
        'latitude': latitude,
        'longitude':longitude
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
          .toList(),
      description: jsonObj['description'] as String,
      latitude: jsonObj['latitude'] as double,
      longitude: jsonObj['longitude'] as double);

  Tasks copy(
          {String? name,
          TaskStatus? status,
          int? completeBeforeDate,
          List<String>? images,
          String? description, double? latitude,
          double? longitude}) =>
      Tasks(
          id: id,
          name: name ?? this.name,
          status: status ?? this.status,
          createdDate: createdDate,
          completeBeforeDate: completeBeforeDate ?? this.completeBeforeDate,
          images: images ?? this.images,
          pin: pin,
          description: description ?? this.description,
          latitude: latitude??this.latitude,
          longitude: longitude??this.longitude);
}

const List<String> TasksColumns = [
  'id',
  'name',
  'status',
  'createdDate',
  'completeBeforeDate',
  'pin',
  'images',
  'description',
  'latitude',
  'longitude'
];

const TasksTableName = "Tasks";
