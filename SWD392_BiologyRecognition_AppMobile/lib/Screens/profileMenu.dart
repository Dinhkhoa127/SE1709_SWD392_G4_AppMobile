import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Helper/UserHelper.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/custom_app_bar.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/login.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/userProfileDetail.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Widgets/footerpage.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/services/api_service.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback? onUserIconTap;

  const ProfileScreen({Key? key, this.onUserIconTap}) : super(key: key);
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String userName = 'Học sinh'; // Giá trị mặc định

  @override
  void initState() {
    super.initState();
    _loadUserName(); // Gọi hàm lấy username khi khởi tạo
  }

  Future<void> _loadUserName() async {
    String userHelperName = await UserHelper.getUserName();
    setState(() {
      userName = userHelperName; // Cập nhật state khi có username từ UserHelper
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        username: userName, // Sử dụng username đã lấy được
        onUserIconTap: widget.onUserIconTap,
      ),
      body: Column(
        children: [
          // Các nút hoặc thông tin ở phía trên
          SizedBox(height: 32),
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserProfileDetailScreen(),
                ),
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
                      await UserHelper.clearUserData(); // Xóa dữ liệu người dùng
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
