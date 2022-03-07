import 'dart:convert';

import 'package:amazon/BloC/add_edit_task_bloc.dart';
import 'package:amazon/db/Tasks.dart';
import 'package:amazon/events/AddEditTaskEvents.dart';
import 'package:amazon/screens/Image_view.dart';
import 'package:amazon/util/TaskStatus.dart';
import 'package:amazon/util/images.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddEditTaskScreen extends StatefulWidget {
  final int taskId;
  final List<String> images;

  const AddEditTaskScreen(
      {Key? key, required this.taskId, required this.images})
      : super(key: key);

  @override
  _AddEditTaskScreenState createState() => _AddEditTaskScreenState();
}

class _AddEditTaskScreenState extends State<AddEditTaskScreen> {
  final _bloc = AddEditTaskBloc();

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
        backgroundColor: Colors.tealAccent,
        title: Text(" Edit Task",
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
                backgroundColor: Colors.tealAccent,
                child: const Icon(Icons.save),
                onPressed: () => {
                  if (task != null)
                    {
                      _bloc.eventsSink.add(OnTaskSubmit(task)),
                      Navigator.pop(
                        context,
                      )
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
                        readOnly: true,
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
                    SizedBox(height: 10.0),
                    Padding(
                      padding: const EdgeInsets.only(left: 25.0),
                      child: Row(
                        children: [
                          const Text(
                            "Status :",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w800),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                            child: DropdownButton<TaskStatus>(
                                items: _bloc
                                    .getPossibleTargetStatuses(
                                        task?.status ?? TaskStatus.PENDING)
                                    .map<DropdownMenuItem<TaskStatus>>(
                                        (status) =>
                                            DropdownMenuItem<TaskStatus>(
                                                child: Text(status.name),
                                                value: status))
                                    .toList(),
                                onChanged: (TaskStatus? value) {
                                  _bloc.eventsSink.add(OnTaskStatusChange(
                                      task: task!.copy(status: value)));
                                  print(value);
                                  if (value == TaskStatus.COMPLETED) {
                                    showDialog(
                                        context: context,
                                        builder: (BuildContext context) {
                                          return _showCompletionDialog(context);
                                        });
                                  }
                                },
                                value: task?.status),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 10.0),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(left: 25.0),
                          child: Text(
                            "Task description",
                            style: TextStyle(
                                fontSize: 18.0, fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    ),

                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20.0, vertical: 10.0),
                      child: TextFormField(
                        readOnly: true,
                        controller: descController,
                        onChanged: (value) {
                          if (task != null) {
                            _bloc.eventsSink.add(OnDescriptionChange(
                                task.copy(description: value)));
                          }
                        },
                        maxLines: 5,
                        decoration: const InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 15.0),
                          fillColor: Colors.white,
                          filled: true,
                          hintText: 'Description',
                        ),
                      ),
                    ),
                    // Padding(
                    //   padding: const EdgeInsets.only(left: 25.0),
                    //   child: Row(
                    //     children: [
                    //       Text(
                    //         "CompleteBeforeDate: ${DateFormat('dd-MM-yyyy').format(DateTime.fromMillisecondsSinceEpoch(task?.completeBeforeDate ?? 0))}",
                    //         style: const TextStyle(
                    //             fontSize: 18.0, fontWeight: FontWeight.w800),
                    //       ),
                    //       IconButton(
                    //           onPressed: () async {
                    //             final date = await showDatePicker(
                    //                 context: context,
                    //                 initialDate: DateTime.now(),
                    //                 firstDate: DateTime.now(),
                    //                 lastDate: DateTime(3022));

                    //             _bloc.eventsSink.add(OnCompleteBeforeDateChange(
                    //                 task: task!.copy(
                    //                     completeBeforeDate:
                    //                         date?.millisecondsSinceEpoch)));
                    //           },
                    //           icon: const Icon(Icons.calendar_today))
                    //     ],
                    //   ),
                    // ),
                    // SizedBox(height: 30.0),

                    Container(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: task?.images.isEmpty ?? true
                            ? 0
                            : task!.images.length,
                        itemBuilder: (context, index) => Container(
                          child: task!.images.isEmpty
                              ? Icon(
                                  CupertinoIcons.camera,
                                  color: Colors.grey.withOpacity(0.5),
                                )
                              : InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ImageView(
                                          imageBase64: task.images[index],
                                        ),
                                      ),
                                    );
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(20),
                                      child: AspectRatio(
                                        aspectRatio: 1,
                                        child: Image.memory(
                                          base64Decode(task.images[index]),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ),
                    ),

                    // Container(
                    //   // color: Colors.tealAccent,
                    //   decoration: BoxDecoration(
                    //     color: Colors.tealAccent,
                    //     borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    //   ),
                    //   child: TextButton(
                    //     onPressed: (() => Navigator.push(
                    //         context,
                    //         MaterialPageRoute(
                    //             builder: (context) => const MapsScreen()))),
                    //     child: const Text(
                    //       "Get delivery address",
                    //       style: TextStyle(
                    //         color: Colors.black,
                    //         fontSize: 20.0,
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      height: 40.0,
                    ),
                    Container(
                      // color: Colors.tealAccent,
                      decoration: BoxDecoration(
                        color: task?.status == TaskStatus.COMPLETED
                            ? Colors.tealAccent
                            : Colors.grey,
                        borderRadius: BorderRadius.all(Radius.circular(10.0)),
                      ),
                      child: TextButton(
                        onPressed: (task?.status != TaskStatus.COMPLETED
                            ? null
                            : () async {
                                List<String>? images = await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const ImageScreen()));
                                print("Images - $images");
                                _bloc.eventsSink.add(
                                    OnImageSelect(task?.copy(images: images)));
                              }),
                        child: const Text(
                          "Add images here",
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 20.0,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }

  Widget _showCompletionDialog(BuildContext context) {
    return AlertDialog(
      title: Text("Task Completed"),
      content: Text("Please add images."),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: Text("OK"),
        )
      ],
    );
  }
}
