import 'package:flutter/material.dart';
import '../Screens/main.dart'; // Import để dùng MainScreen

class FooterPage extends StatelessWidget {
  // currentIndex: tab hiện tại đang active
  final int currentIndex;

  const FooterPage({Key? key, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      currentIndex: currentIndex,
      onTap: (index) => _navigateToPage(context, index),
      items: const [
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
    );
  }

  // Hàm điều hướng về MainScreen với tab được chọn
  void _navigateToPage(BuildContext context, int index) {
    // Nếu đã ở tab này rồi thì không cần làm gì
    if (index == currentIndex) return;

    // Điều hướng về MainScreen với tab được chọn
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MainScreen(initialIndex: index)),
      (route) => false, // Xóa tất cả các màn hình cũ
    );
  }
}
