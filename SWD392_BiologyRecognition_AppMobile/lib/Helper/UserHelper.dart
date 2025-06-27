import 'package:shared_preferences/shared_preferences.dart';

class UserHelper {
  // Lấy username từ SharedPreferences
  static Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName') ?? 'Học sinh';
  }

  // Lấy token xác thực
  static Future<String?> getAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken');
  }

  // Kiểm tra người dùng đã đăng nhập chưa
  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') != null;
  }

  // Xóa dữ liệu người dùng khi đăng xuất
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('accessToken');
  }
}
