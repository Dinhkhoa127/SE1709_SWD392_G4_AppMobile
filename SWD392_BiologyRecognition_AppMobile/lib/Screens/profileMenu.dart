import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/custom_app_bar.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/login.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Widgets/footerpage.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/services/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
                onPressed: () async {
                  try {
                    // Truyền một object rỗng {}
                    final response = await ApiService.postData(
                      'authentication/logout',
                      {},
                    );

                    if (response.statusCode == 200) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => LoginScreen()),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đăng xuất thất bại')),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Lỗi: ${e.toString()}')),
                    );
                  }
                },
                child: Text('Đăng xuất'), // Sửa text cho đúng với chức năng
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: FooterPage(currentIndex: 3),
    );
  }
}
