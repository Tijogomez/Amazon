import 'package:amazon/BloC/logger_bloc.dart';
import 'package:amazon/db/log.dart';
import 'package:amazon/events/LogEvents.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class LogScreen extends StatefulWidget {
  const LogScreen({Key? key}) : super(key: key);

  @override
  _LogScreenState createState() => _LogScreenState();
}

class _LogScreenState extends State<LogScreen> {
  final _bloc = LoggerBloc();

  @override
  void initState() {
    _bloc.initState();
    super.initState();
  }

  @override
  void dispose() {
    _bloc.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.tealAccent,
        title: Text(
          "Logger",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: StreamBuilder<List<Log>>(
            initialData: const [],
            stream: _bloc.logs,
            builder: (BuildContext context, AsyncSnapshot<List<Log>> snapshot) {
              final logs = snapshot.data;
              if (logs == null) {
                return const Text("No Data");
              } else {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: logs.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                                child: ListTile(
                              leading: Text(logs[index].username),
                              title: Text(logs[index].event.name +
                                  ' at ' +
                                  DateFormat('dd-MM-yyyy').format(
                                      DateTime.fromMillisecondsSinceEpoch(
                                          logs[index].date))),
                            ));
                          }),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          TextButton(
                              onPressed: () async {
                                _bloc.eventsink.add(OnPrevClick());
                              },
                              child: Icon(
                                Icons.arrow_circle_left_sharp,
                                size: 40,
                              )),
                          TextButton(
                              onPressed: () async {
                                _bloc.eventsink.add(OnNextClick());
                              },
                              child: Icon(
                                Icons.arrow_circle_right_sharp,
                                size: 40,
                              )),
                        ],
                      )
                    ],
                  ),
                );
              }
            }),
      ),
    );
  }
}
