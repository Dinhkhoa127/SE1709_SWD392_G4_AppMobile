import 'package:flutter/material.dart';
import '../main.dart'; // Import để dùng MainScreen

class FooterPage extends StatelessWidget {
  // currentIndex: tab hiện tại đang active
  final int currentIndex;

  const FooterPage({Key? key, required this.currentIndex}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            spreadRadius: 0,
            blurRadius: 15,
            offset: Offset(0, -3),
          ),
        ],
        border: Border(
          top: BorderSide(color: Colors.grey.withOpacity(0.2), width: 0.5),
        ),
      ),
      child: SafeArea(
        child: Container(
          height: 65, // Tăng lên 65 để đủ chỗ
          padding: EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ), // Tăng vertical padding
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                context,
                index: 0,
                icon: Icons.home_rounded,
                label: 'Home',
                isActive: currentIndex == 0,
              ),
              _buildNavItem(
                context,
                index: 1,
                icon: Icons.search_rounded,
                label: 'Tra cứu',
                isActive: currentIndex == 1,
              ),
              _buildNavItem(
                context,
                index: 2,
                icon: Icons.camera_alt_rounded,
                label: 'Nhận diện',
                isActive: currentIndex == 2,
              ),
              _buildNavItem(
                context,
                index: 3,
                icon: Icons.person_rounded,
                label: 'Profile',
                isActive: currentIndex == 3,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required int index,
    required IconData icon,
    required String label,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => _navigateToPage(context, index),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: 2,
            vertical: 0,
          ), // Giảm padding tối đa
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon lớn hơn, bỏ container wrapper
              Icon(
                icon,
                size: 24, // Tăng từ 18 lên 24
                color: isActive ? Color(0xFF4CAF50) : Colors.grey[600],
              ),

              SizedBox(height: 4), // Tăng spacing cho đẹp
              // Label
              Text(
                label,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10, // Tăng từ 9 lên 10
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? Color(0xFF4CAF50) : Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Hàm điều hướng về MainScreen với tab được chọn
  void _navigateToPage(BuildContext context, int index) {
    // Nếu đã ở tab này rồi thì không cần làm gì
    if (index == currentIndex) return;

    // Điều hướng về MainScreen với tab được chọn
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => MainScreen(initialIndex: index)),
      (route) => false,
    );
  }
}
