import 'dart:io';
import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImageScreen extends StatefulWidget {
  const ImageScreen({Key? key}) : super(key: key);

  @override
  _ImageScreenState createState() => _ImageScreenState();
}

class _ImageScreenState extends State<ImageScreen> {
  final imagePicker = ImagePicker();
  List<String>? images = [];

  @override
  Widget build(BuildContext context) {
    print("Display images");
    return Scaffold(
        appBar: AppBar(
          title: const Text('Add Images'),
        ),
        floatingActionButton: FloatingActionButton(
          child: const Icon(Icons.save),
          onPressed: () => Navigator.pop(context, images),
        ),
        body: Container(
          child: InkWell(
            onTap: () {
              getMultiImages();
            },
            child: GridView.builder(
              itemCount: images!.isEmpty ? 1 : images!.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4),
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.grey.withOpacity(0.5))),
                child: images!.isEmpty
                    ? Icon(
                        CupertinoIcons.camera,
                        color: Colors.grey.withOpacity(0.5),
                      )
                    : Image.memory(
                        base64Decode(images![index]),
                        fit: BoxFit.cover,
                      ),
              ),
            ),
          ),
        ));
  }

  Future getMultiImages() async {
    final XFile? image =
        await imagePicker.pickImage(source: ImageSource.gallery);
    File file = File(image!.path);
    List<int> fileInByte = file.readAsBytesSync();
    String fileInBase64 = base64Encode(fileInByte);
    setState(() {
      images!.add(fileInBase64);
      print("Adding to list");
    });
  }
}
