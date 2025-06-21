import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/custom_app_bar.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/login.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Widgets/footerpage.dart';

class ProfileScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(username: 'User123'),
      body: Column(
        children: [
          // Các nút hoặc thông tin ở phía trên
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            child: Text('Thông tin cá nhân'),
          ),
          ElevatedButton(onPressed: () {}, child: Text('Lịch sử nhận diện')),
          Spacer(), // Đẩy các nút phía trên lên, nút đăng xuất xuống dưới
          Padding(
            padding: const EdgeInsets.only(bottom: 40.0),
            child: Center(
              child: ElevatedButton(
                child: Text('Đăng xuất'),
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => LoginScreen()),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FooterPage(currentIndex: 3),
    );
  }
}
