import 'package:amazon/BloC/home_bloc.dart';
import 'package:amazon/db/Tasks.dart';
import 'package:amazon/events/TaskListEvents.dart';
import 'package:amazon/screens/AddEditTaskScreen.dart';
import 'package:amazon/screens/log_screen.dart';
import 'package:amazon/util/TaskStatus.dart';
import 'package:amazon/widgets/custom_drawer.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bloc = HomeBloc();

  @override
  void initState() {
    super.initState();
    _bloc.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.tealAccent,
        iconTheme: IconThemeData(
          color: Theme.of(context).primaryColor,
        ),
        title: const Text(
          'AmAZoN',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            letterSpacing: 5.0,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _bloc.eventSink.add(OnRefresh());
            },
          ),
        ],
      ),
      drawer: CustomDrawer(),
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      'Tasks',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(
                      height: 50.0,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(cardColor: Colors.tealAccent),
                        child: PopupMenuButton(
                          child: const Text(
                            "By Status",
                            style: TextStyle(
                              backgroundColor: Colors.tealAccent,
                            ),
                          ),
                          itemBuilder: (_) {
                            return TaskStatus.values
                                .map((status) => PopupMenuItem(
                                    child: Text(status.name),
                                    onTap: () {
                                      _bloc.eventSink.add(
                                          OnStatusFilterSelect(status: status));
                                    }))
                                .toList();
                          },
                        ),
                      ),
                    ),
                    TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1022),
                              lastDate: DateTime(3022));

                          _bloc.eventSink.add(OnCreatedDateFilterSelect(
                              date: date ?? DateTime.now()));
                        },
                        child: const Text(
                          "By Created Date",
                          style: TextStyle(backgroundColor: Colors.tealAccent),
                        )),
                    TextButton(
                        onPressed: () async {
                          final date = await showDatePicker(
                              context: context,
                              initialDate: DateTime.now(),
                              firstDate: DateTime(1022),
                              lastDate: DateTime(3022));

                          _bloc.eventSink.add(OnCompleteByDateFilterSelect(
                              date: date ?? DateTime.now()));
                        },
                        child: const Text(
                          "By Complete Date",
                          style: TextStyle(backgroundColor: Colors.tealAccent),
                        )),
                  ],
                ),
              ),
              StreamBuilder<List<Tasks>>(
                  stream: _bloc.tasks,
                  initialData: const [],
                  builder: (BuildContext context,
                      AsyncSnapshot<List<Tasks>> snapshot) {
                    final _snapshotData = snapshot.data;
                    if (_snapshotData == null) {
                      return const Padding(
                        padding: EdgeInsets.only(top: 50.0),
                        child: Center(
                          child: CircularProgressIndicator(),
                        ),
                      );
                    } else {
                      return ListView.builder(
                          scrollDirection: Axis.vertical,
                          shrinkWrap: true,
                          itemCount: _snapshotData.length,
                          itemBuilder: (BuildContext context, int index) {
                            return Card(
                                child: ListTile(
                                    leading: Text(_snapshotData[index].name),
                                    title: Text(
                                      _snapshotData[index].status.name,
                                    ),
                                    tileColor: _bloc.getColorForStatus(
                                        _snapshotData[index].status),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddEditTaskScreen(
                                                    taskId: _snapshotData[index]
                                                        .id),
                                          ));
                                    }));
                          });
                    }
                  }),
            ],
          ),
        ),
      ),
      floatingActionButton: Stack(
        fit: StackFit.loose,
        children: [
          Positioned(
            bottom: 80,
            right: 20,
            child: Theme(
              data: Theme.of(context).copyWith(highlightColor: Colors.black),
              child: FloatingActionButton(
                backgroundColor: Colors.tealAccent,
                child: const Icon(Icons.local_activity),
                onPressed: () => Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const LogScreen())),
                heroTag: "Log Fab",
              ),
            ),
          ),
          Positioned(
              bottom: 10,
              right: 20,
              child: Theme(
                data: Theme.of(context).copyWith(highlightColor: Colors.black),
                child: FloatingActionButton(
                  backgroundColor: Colors.tealAccent,
                  child: const Icon(Icons.add),
                  onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              const AddEditTaskScreen(taskId: -1))),
                  heroTag: "Add Edit Task Fab",
                ),
              )),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
