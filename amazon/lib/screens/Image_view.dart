import 'dart:convert';

import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final String imageBase64;
  const ImageView({Key? key, required this.imageBase64}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
      backgroundColor: Colors.black,
      body: SizedBox.expand(
        child: Center(
          child: Stack(
            children: [
              Image.memory(
                base64Decode(imageBase64),
                fit: BoxFit.cover,
              ),
              Positioned(
                top: 20,
                left: 20,
                child: InkWell(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    height: 30,
                    width: 30,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.black54,
                    ),
                    child: Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}
