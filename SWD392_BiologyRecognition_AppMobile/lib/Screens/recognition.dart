import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../services/cloudinary_service.dart';
import 'recognitionResult.dart';

class RecognitionScreen extends StatefulWidget {
  @override
  _RecognitionScreenState createState() => _RecognitionScreenState();
}

class _RecognitionScreenState extends State<RecognitionScreen> {
  bool _isUploading = false;

  Future<void> _pickAndUploadImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.camera);

    if (pickedFile != null) {
      setState(() {
        _isUploading = true;
      });

      // Upload lên Cloudinary
      final url = await CloudinaryService.uploadImage(File(pickedFile.path));

      setState(() {
        _isUploading = false;
      });

      if (url != null) {
        // Chuyển sang màn hình kết quả và truyền link ảnh
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RecognitionResultScreen(imageUrl: url),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload thất bại!')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recognition')),
      body: Center(
        child: _isUploading
            ? CircularProgressIndicator()
            : ElevatedButton(
                onPressed: _pickAndUploadImage,
                child: Text('Chụp & Upload ảnh'),
              ),
      ),
    );
  }
}
