import 'package:amazon/util/TaskStatus.dart';

class Log {
  final int id;
  final String username;
  final TaskStatus event;
  final int date;

  const Log({
    required this.username,
    required this.event,
    this.id = -1,
    required this.date,
  });

  Map<String, Object?> toJson() => {
        'username': username,
        'event': event.name,
        'date': date,
      };

  static Log fromJson(Map<String, Object?> json) => Log(
        id: json['id'] as int,
        username: json['username'] as String,
        event: TaskStatus.values.byName(json['event'] as String),
        date: json['date'] as int,
      );

  Log copy({String? username, TaskStatus? event}) => Log(
      id: id,
      username: username ?? this.username,
      event: event ?? this.event,
      date: date);
}

const List<String> LogColumns = [
  'id',
  'username',
  'event',
  'date',
];

const LogTableName = "Log";
