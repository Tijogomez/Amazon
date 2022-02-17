import 'dart:async';
import 'package:amazon/BloC/bloc.dart';
import 'package:amazon/BloC/logger.dart';
import 'package:amazon/db/log.dart';
import 'package:amazon/events/LogEvents.dart';

class LoggerBloc extends Bloc {
  final _logger = Logger();

  int _currentPage = 0;

  final StreamController<List<Log>> _logsController = StreamController();
  Stream<List<Log>> get logs => _logsController.stream;

  final StreamController<LogEvents> _eventsController = StreamController();
  Sink<LogEvents> get eventsink => _eventsController.sink;

  void initState() {
    _getLogs();
  }

  void _onEvent(LogEvents event) {
    if (event is OnNextClick) {
      _getNextLogPage();
    } else if (event is OnPrevClick) {
      _getPrevLogPage();
    }
  }

  void _getLogs() async {
    _logsController.sink.add(await _logger.getLogs(_currentPage));
  }

  void _getNextLogPage() {
    _currentPage += 1;
    _getLogs();
  }

  void _getPrevLogPage() {
    _currentPage -= 1;
    _getLogs();
  }

  LoggerBloc() {
    _eventsController.stream.listen((event) {
      _onEvent(event);
    });
  }

  @override
  void dispose() {
    _logsController.close();
  }
}
