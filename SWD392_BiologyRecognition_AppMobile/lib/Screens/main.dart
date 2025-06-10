import 'package:flutter/material.dart';
import 'biology_search.dart';
import 'home.dart';
import 'profileMenu.dart';
import 'recognition.dart';
import 'login.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Bio Recognition App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: LoginScreen(),
    );
  }
}

class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  void goToProfileTab() {
    setState(() {
      _currentIndex = 3; // Index của Profile tab
    });
  }

  void goToRecognitionTab() {
    setState(() {
      _currentIndex = 2; // Index của Recognition tab
    });
  }

  // Thêm hàm này để xử lý khi bấm vào các tab
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      HomeScreen(
        onUserIconTap: goToProfileTab,
        onRecognitionTap: goToRecognitionTab,
      ),
      BiologySearchTab(onUserIconTap: goToProfileTab),
      RecognitionScreen(),
      ProfileScreen(),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        currentIndex: _currentIndex,
        onTap: onTabTapped, // Đã có hàm này
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Biology Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Recognition',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
