import 'dart:io';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class FullImageViewer extends StatelessWidget {
  final File image;

  const FullImageViewer({super.key, required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.black),
      body: PhotoView(
        imageProvider: FileImage(image),
      ),
    );
  }
}
