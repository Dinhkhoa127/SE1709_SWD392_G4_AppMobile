import 'package:flutter/material.dart';

class RecognitionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Text(
          'Recognition Screen',
          style: TextStyle(
            fontSize: 24,
            color: Colors.black,
            decoration: TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
