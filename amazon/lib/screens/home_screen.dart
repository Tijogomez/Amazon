import 'dart:convert';

import 'package:amazon/BloC/home_bloc.dart';
import 'package:amazon/db/Tasks.dart';
import 'package:amazon/db/User.dart';
import 'package:amazon/db/UserDataSource.dart';
import 'package:amazon/events/TaskListEvents.dart';
import 'package:amazon/main.dart';
import 'package:amazon/screens/AddEditTaskScreen.dart';
import 'package:amazon/screens/create_task_page.dart';
import 'package:amazon/screens/log_screen.dart';
import 'package:amazon/util/TaskStatus.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _bloc = HomeBloc();

  Future<User?> getUser() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return await UserDataSource().loginUser(prefs.getString('userName') ?? '');
  }

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

  setLoggedOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', false);
    print("Logged out");
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getUser(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          User? user = snapshot.data as User?;
          return Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              centerTitle: true,
              backgroundColor: Colors.orangeAccent,
              iconTheme: IconThemeData(
                color: Theme.of(context).primaryColor,
              ),
              leading: Padding(
                padding: const EdgeInsets.all(10.0),
                child: PopupMenuButton(
                  onSelected: (value) {
                    if (value == 'logout') {
                      setLoggedOut();
                      Navigator.of(context, rootNavigator: true)
                          .pushReplacement(
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
                    child: Text(
                      user?.username.substring(0, 1) ?? 'U',
                    ),
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
              title: Text(
                user?.username ?? "User",
                style: TextStyle(
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2.0,
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
            // drawer: CustomDrawer(),
            body: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TaskHeader(blocData: _bloc),
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
                            return Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0,
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Container(
                                        width: 40,
                                        child: Text(
                                          "ID",
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Taskname",
                                          style: TextStyle(fontSize: 17),
                                        ),
                                      ),
                                      Expanded(
                                        child: Text(
                                          "Status",
                                          style: TextStyle(fontSize: 17),
                                          textAlign: TextAlign.end,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Container(
                                  // height:
                                  //     MediaQuery.of(context).size.height * 0.65,
                                  width: MediaQuery.of(context).size.width,
                                  child: ListView.builder(
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      scrollDirection: Axis.vertical,
                                      shrinkWrap: true,
                                      itemCount: _snapshotData.length,
                                      itemBuilder:
                                          (BuildContext context, int index) {
                                        return InkWell(
                                          onTap: () => Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    AddEditTaskScreen(
                                                  taskId:
                                                      _snapshotData[index].id,
                                                  images: _snapshotData[index]
                                                      .images,
                                                  homeBloc: _bloc,
                                                ),
                                              )),
                                          child: Card(
                                              color: _bloc.getColorForStatus(
                                                  _snapshotData[index].status),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(14.0),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Container(
                                                      child: Text(
                                                        _snapshotData[index]
                                                            .pin
                                                            .toString(),
                                                        style: const TextStyle(
                                                          fontSize: 18,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              0.6,
                                                      child: Text(
                                                        _snapshotData[index]
                                                            .name,
                                                        style: const TextStyle(
                                                          fontSize: 15,
                                                          fontWeight:
                                                              FontWeight.w500,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                    Container(
                                                      child: Text(
                                                        _snapshotData[index]
                                                            .status
                                                            .name,
                                                      ),
                                                    ),
                                                    // ListTile(
                                                    //     leading: Text(
                                                    //       _snapshotData[index]
                                                    //           .pin
                                                    //           .toString(),
                                                    //       style: const TextStyle(
                                                    //         fontSize: 18,
                                                    //         fontWeight: FontWeight.bold,
                                                    //       ),
                                                    //     ),
                                                    //     title: Text(
                                                    //       _snapshotData[index].name +
                                                    //           "       " +
                                                    //           _snapshotData[index]
                                                    //               .status
                                                    //               .name,
                                                    //       style: const TextStyle(
                                                    //         fontSize: 15,
                                                    //         fontWeight: FontWeight.w500,
                                                    //       ),
                                                    //     ),
                                                    //     tileColor:
                                                    //         _bloc.getColorForStatus(
                                                    //             _snapshotData[index]
                                                    //                 .status),
                                                    //     onTap: () {
                                                    //       Navigator.push(
                                                    //           context,
                                                    //           MaterialPageRoute(
                                                    //             builder: (context) =>
                                                    //                 AddEditTaskScreen(
                                                    //                     taskId:
                                                    //                         _snapshotData[
                                                    //                                 index]
                                                    //                             .id,
                                                    //                     images:
                                                    //                         _snapshotData[
                                                    //                                 index]
                                                    //                             .images),
                                                    //           ));
                                                    //     }),
                                                  ],
                                                ),
                                              )),
                                        );
                                      }),
                                ),
                              ],
                            );
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
                //       backgroundColor: Colors.orangeAccent,
                //       child: const Icon(Icons.local_activity),
                //       onPressed: () => Navigator.push(context,
                //           MaterialPageRoute(builder: (context) => const LogScreen())),
                //       heroTag: "Log Fab",
                //     ),
                //   ),
                // ),
                Positioned(
                    bottom: 5,
                    right: 20,
                    child: Theme(
                      data: Theme.of(context)
                          .copyWith(highlightColor: Colors.black),
                      child: FloatingActionButton(
                        backgroundColor: Colors.orangeAccent,
                        child: const Icon(Icons.add),
                        onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CreateTask(
                                      taskId: -1,
                                      homeBloc: _bloc,
                                    ))),
                        heroTag: "Create Task Fab",
                      ),
                    )),
              ],
            ),
            floatingActionButtonLocation:
                FloatingActionButtonLocation.centerFloat,
          );
        } else {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}

class TaskHeader extends StatefulWidget {
  HomeBloc blocData;

  TaskHeader({Key? key, required this.blocData}) : super(key: key);

  @override
  State<TaskHeader> createState() => _TaskHeaderState();
}

class _TaskHeaderState extends State<TaskHeader> {
  bool _expandSort = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
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
                    color: Colors.orangeAccent,
                    shape: CircleBorder(),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.sort),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        _expandSort = !_expandSort;
                      });
                    },
                  ),
                )
              ],
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 500),
            height: _expandSort ? 50 : 0,
            curve: Curves.easeInOut,
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Theme(
                      data: Theme.of(context).copyWith(cardColor: Colors.white),
                      child: PopupMenuButton(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.orangeAccent,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10.0)),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: const Text("By Status",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600)),
                          ),
                        ),
                        itemBuilder: (_) {
                          return TaskStatus.values
                              .map((status) => PopupMenuItem(
                                  child: Text(status.name),
                                  onTap: () {
                                    widget.blocData.eventSink.add(
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

                        widget.blocData.eventSink.add(OnCreatedDateFilterSelect(
                            date: date ?? DateTime.now()));
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.orangeAccent,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: const Text(
                            "By Created Date",
                            style: TextStyle(
                              color: Colors.black,
                            ),
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

                      widget.blocData.eventSink.add(
                          OnCompleteByDateFilterSelect(
                              date: date ?? DateTime.now()));
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.orangeAccent,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: const Text(
                          "By Completed Date ",
                          style: TextStyle(
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => widget.blocData.eventSink.add(OnRefresh()),
                    child: Container(
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            "Clear Filters",
                            style: TextStyle(
                              color: Colors.white,
                            ),
                          ),
                        )),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
