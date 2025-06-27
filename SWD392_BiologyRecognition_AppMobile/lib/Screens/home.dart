import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/custom_app_bar.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Widgets/footerpage.dart';
import '../Helper/UserHelper.dart'; // Import UserHelper

class HomeScreen extends StatefulWidget {
  // Chuyển sang StatefulWidget
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
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String username = 'Học sinh'; // Giá trị mặc định

  @override
  void initState() {
    super.initState();
    _loadUsername(); // Gọi hàm lấy username khi khởi tạo
  }

  // Hàm lấy username từ UserHelper
  Future<void> _loadUsername() async {
    String name = await UserHelper.getUserName();
    setState(() {
      username = name; // Cập nhật state khi có username từ SharedPreferences
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        username: username, // Sử dụng username đã lấy được
        onUserIconTap: widget.onUserIconTap,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: widget.onRecognitionTap,
              child: Text('Nhận diện sinh vật'),
            ),
            ElevatedButton(
              onPressed: widget.onBiologyResearchTap,
              child: Text('Tra cứu sinh vật'),
            ),
          ],
        ),
      ),
      bottomNavigationBar: FooterPage(currentIndex: 0),
    );
  }
}
