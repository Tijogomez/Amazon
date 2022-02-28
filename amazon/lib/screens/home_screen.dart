import 'dart:convert';

import 'package:amazon/BloC/home_bloc.dart';
import 'package:amazon/db/Tasks.dart';
import 'package:amazon/db/UserDataSource.dart';
import 'package:amazon/events/TaskListEvents.dart';
import 'package:amazon/main.dart';
import 'package:amazon/screens/AddEditTaskScreen.dart';
import 'package:amazon/screens/log_screen.dart';
import 'package:amazon/util/TaskStatus.dart';
import 'package:amazon/widgets/custom_drawer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bloc = HomeBloc();
  final user = UserDataSource.loggedInUser;
  bool _expandSort = false;

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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Expanded(
              flex: 1,
              child: PopupMenuButton(
                onSelected: (value) {
                  if (value == 'logout') {
                    Navigator.of(context, rootNavigator: true).pushReplacement(
                      new MaterialPageRoute(
                        builder: (BuildContext context) => new MyApp(),
                      ),
                    );
                  } else if (value == 'logger') {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new LogScreen()));
                  }
                },
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.grey,
                  child: Text("${user!.username.substring(0, 1)}"),
                  radius: 20,
                ),
                itemBuilder: (context) => [
                  PopupMenuItem(
                    child: Text("Logger"),
                    value: "logger",
                  ),
                  PopupMenuItem(
                    child: Text("Logout"),
                    value: "logout",
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Text(
                user!.username,
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ],
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
      // drawer: CustomDrawer(),
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
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    const Text(
                      'Active Tasks',
                      style: TextStyle(
                        fontSize: 20.0,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(
                      height: 50.0,
                    ),
                    Ink(
                      decoration: const ShapeDecoration(
                        color: Colors.tealAccent,
                        shape: CircleBorder(),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.filter_alt_outlined),
                        onPressed: () {
                          setState(() {
                            _expandSort = !_expandSort;
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: MediaQuery.of(context).size.width,
                height:
                    _expandSort ? MediaQuery.of(context).size.height * 0.07 : 0,
                curve: Curves.ease,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: Theme(
                        data: Theme.of(context)
                            .copyWith(cardColor: Colors.tealAccent),
                        child: PopupMenuButton(
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.tealAccent,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(10.0)),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: const Text("By Status",
                                  style: TextStyle(
                                      color: Colors.blue,
                                      fontWeight: FontWeight.w600)),
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.tealAccent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                              "By Created Date",
                            ),
                          ),
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
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.tealAccent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Text(
                              "By Completed Date ",
                            ),
                          ),
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
                                    // trailing: GridView.builder(
                                    //   itemCount: _snapshotData[index]
                                    //           .images
                                    //           .isEmpty
                                    //       ? 1
                                    //       : _snapshotData[index].images.length,
                                    //   gridDelegate:
                                    //       SliverGridDelegateWithFixedCrossAxisCount(
                                    //           crossAxisCount: 3),
                                    //   itemBuilder: (context, index) =>
                                    //       Container(
                                    //     decoration: BoxDecoration(
                                    //         color: Colors.white,
                                    //         border: Border.all(
                                    //             color: Colors.grey
                                    //                 .withOpacity(0.5))),
                                    //     child:
                                    //         _snapshotData[index].images.isEmpty
                                    //             ? Icon(
                                    //                 CupertinoIcons.camera,
                                    //                 color: Colors.grey
                                    //                     .withOpacity(0.5),
                                    //               )
                                    //             : Image.memory(
                                    //                 base64Decode(
                                    //                     _snapshotData[index]
                                    //                         .images[index]),
                                    //                 fit: BoxFit.cover,
                                    //               ),
                                    //   ),
                                    // ),
                                    tileColor: _bloc.getColorForStatus(
                                        _snapshotData[index].status),
                                    onTap: () {
                                      Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AddEditTaskScreen(
                                                    taskId:
                                                        _snapshotData[index].id,
                                                    images: _snapshotData[index]
                                                        .images),
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
          // Positioned(
          //   bottom: 80,
          //   right: 20,
          //   child: Theme(
          //     data: Theme.of(context).copyWith(highlightColor: Colors.black),
          //     child: FloatingActionButton(
          //       backgroundColor: Colors.tealAccent,
          //       child: const Icon(Icons.local_activity),
          //       onPressed: () => Navigator.push(context,
          //           MaterialPageRoute(builder: (context) => const LogScreen())),
          //       heroTag: "Log Fab",
          //     ),
          //   ),
          // ),
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
                          builder: (context) => const AddEditTaskScreen(
                                taskId: -1,
                                images: [],
                              ))),
                  heroTag: "Add Edit Task Fab",
                ),
              )),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
