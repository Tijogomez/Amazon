import 'package:amazon/BloC/add_edit_task_bloc.dart';
import 'package:amazon/BloC/home_bloc.dart';
import 'package:amazon/db/Tasks.dart';
import 'package:amazon/events/AddEditTaskEvents.dart';
import 'package:amazon/events/TaskListEvents.dart';
import 'package:amazon/screens/maps.dart';
import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';

class CreateTask extends StatefulWidget {
  final int taskId;
  final HomeBloc homeBloc;
  const CreateTask({Key? key, required this.taskId, required this.homeBloc})
      : super(key: key);

  @override
  State<CreateTask> createState() => _CreateTaskState();
}

class _CreateTaskState extends State<CreateTask> {
  final _bloc = AddEditTaskBloc();
  TextEditingController locationTextController = TextEditingController();
  @override
  void initState() {
    super.initState();
    _bloc.initState(widget.taskId);
  }

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController();
    final descController = TextEditingController();

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.orangeAccent,
        title: Text(" Add Task",
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
      ),
      body: StreamBuilder<Tasks>(
        initialData: null,
        stream: _bloc.taskStream,
        builder: (BuildContext context, AsyncSnapshot<Tasks> snapshot) {
          final task = snapshot.data;
          textController.value =
              textController.value.copyWith(text: task?.name);
          descController.value =
              descController.value.copyWith(text: task?.description);
          return Scaffold(
            floatingActionButton: FloatingActionButton(
              backgroundColor: Colors.orangeAccent,
              child: const Icon(Icons.save),
              onPressed: () {
                if (task != null) {
                  _bloc.eventsSink.add(OnTaskSubmit(task));
                  widget.homeBloc.eventSink.add(OnRefresh());
                  Navigator.pop(
                    context,
                  );
                }
              },
            ),
            body: Padding(
              padding: const EdgeInsets.only(top: 30.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20.0, vertical: 10.0),
                    child: TextFormField(
                      controller: textController,
                      onChanged: (value) {
                        if (task != null) {
                          _bloc.eventsSink.add(
                              OnTaskNameChange(task: task.copy(name: value)));
                        }
                      },
                      decoration: const InputDecoration(
                        contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                        fillColor: Colors.white,
                        filled: true,
                        hintText: 'Task Name',
                        prefixIcon: Icon(
                          Icons.task,
                          size: 30.0,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Card(
                      color: Colors.white,
                      child: Padding(
                        padding: EdgeInsets.all(8.0),
                        child: TextFormField(
                          controller: descController,
                          onChanged: (value) {
                            if (task != null) {
                              _bloc.eventsSink.add(OnDescriptionChange(
                                  task.copy(description: value)));
                            }
                          },
                          maxLines: 5,
                          decoration: InputDecoration.collapsed(
                              hintText: "Add description"),
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 25.0),
                    child: Row(
                      children: [
                        Text(
                          "CompleteBeforeDate: ${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(task?.completeBeforeDate ?? 0))}",
                          style: const TextStyle(
                              fontSize: 18.0, fontWeight: FontWeight.w800),
                        ),
                        IconButton(
                            onPressed: () async {
                              final date = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime.now(),
                                  lastDate: DateTime(3022));

                              _bloc.eventsSink.add(OnCompleteBeforeDateChange(
                                  task: task!.copy(
                                      completeBeforeDate:
                                          date?.millisecondsSinceEpoch)));
                            },
                            icon: const Icon(Icons.calendar_today))
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 25.0,
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(children: [
                      Expanded(
                        child: Container(
                          height: 80,
                          child: TextField(
                            keyboardType: TextInputType.multiline,
                            controller: locationTextController,
                            style: const TextStyle(
                                fontSize: 16, color: Colors.black),
                            decoration: const InputDecoration(
                                hintText: 'Select delivery location from map',
                                border: OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: 2.0,
                                        color: Colors.orangeAccent)),
                                prefixIcon: Icon(Icons.location_city,
                                    color: Colors.orangeAccent)),
                            enabled: false,
                            maxLines: null,
                            minLines: null,
                            expands: true,
                          ),
                        ),
                      ),
                      Container(
                        height: 80,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          border: Border.all(
                            color: Colors.orangeAccent,
                            width: 1,
                          ),
                        ),
                        child: IconButton(
                          onPressed: (() async {
                            final value = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => const MapsScreen()));

                            setTextLocation(value);
                            _bloc.eventsSink.add(OnLocationChange(
                                task: task!.copy(
                                    latitude: value.latitude,
                                    longitude: value.longitude)));
                          }),
                          icon: Icon(
                            Icons.location_on_outlined,
                            size: 35,
                          ),
                        ),
                      )
                    ]),
                  )
                  // Container(
                  //   // color: Colors.orangeAccent,
                  //   decoration: BoxDecoration(
                  //     color: Colors.orangeAccent,
                  //     borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  //   ),
                  //   child: TextButton(
                  // onPressed: (() {
                  //   final result = Navigator.push(
                  //       context,
                  //       MaterialPageRoute(
                  //           builder: (context) => const MapsScreen()));
                  //   result.then((value) {
                  //      _bloc.eventsSink.add(OnLocationChange(
                  //       task: task!.copy(latitude: value.latitude, longitude: value.longitude)));
                  //   });

                  //     }),
                  //     child: const Text(
                  //       "Get delivery address",
                  //       style: TextStyle(
                  //         color: Colors.black,
                  //         fontSize: 20.0,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void setTextLocation(value) async {
    List<Placemark> placemarks =
        await placemarkFromCoordinates(value.latitude, value.longitude);
    locationTextController.text = placemarks != null && placemarks.length > 0
        ? '${placemarks[1].street ?? placemarks[0].street} ${placemarks[1].subLocality ?? placemarks[0].subLocality} ${placemarks[1].locality ?? placemarks[0].locality} ${placemarks[1].postalCode ?? placemarks[0].postalCode}'
        : 'unnamed';
  }
}
