import 'package:flutter/material.dart';
import 'dart:io';

import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/recognition.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Widgets/footerpage.dart';

class RecognitionResultScreen extends StatelessWidget {
  final File imageFile;

  const RecognitionResultScreen({Key? key, required this.imageFile})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recognition Result')),
      body: Center(
        child: Column(
          children: [
            SizedBox(
              width: 400, // Giới hạn chiều rộng ảnh
              height: 200, // Giới hạn chiều cao ảnh
              child: Image.file(imageFile, fit: BoxFit.contain),
            ),
            SizedBox(height: 20),
            Text('Kết quả tìm kiếm', style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => RecognitionScreen()),
          );
        },
        child: Icon(Icons.camera),
      ),
      bottomNavigationBar: FooterPage(currentIndex: 2),
    );
  }
}
