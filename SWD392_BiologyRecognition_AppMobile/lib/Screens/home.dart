import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/custom_app_bar.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onUserIconTap;
  final VoidCallback? onRecognitionTap;
  const HomeScreen({Key? key, this.onUserIconTap, this.onRecognitionTap})
    : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(username: 'User123', onUserIconTap: onUserIconTap),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: onRecognitionTap,
              child: Text('Nhận diện sinh vật'),
            ),
          ],
        ),
      ),
    );
  }
}
