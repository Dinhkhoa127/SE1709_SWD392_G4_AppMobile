import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/custom_app_bar.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Widgets/footerpage.dart';

class HomeScreen extends StatelessWidget {
  final VoidCallback? onUserIconTap;
  final VoidCallback? onRecognitionTap;
  final VoidCallback? onBiologyResearchTap;
  const HomeScreen({
    Key? key,
    this.onUserIconTap,
    this.onRecognitionTap,
    this.onBiologyResearchTap,
  }) : super(key: key);

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
            ElevatedButton(
              onPressed: onBiologyResearchTap,
              child: Text('Tra cứu sinh vật'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FooterPage(currentIndex: 0),
    );
  }
}
