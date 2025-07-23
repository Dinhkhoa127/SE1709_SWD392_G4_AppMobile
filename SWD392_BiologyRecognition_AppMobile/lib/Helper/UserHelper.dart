import 'package:shared_preferences/shared_preferences.dart';

class UserHelper {
  // ===== SAVE METHODS =====

  // Lưu username vào SharedPreferences
  static Future<void> saveUserName(String userName) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', userName);
  }

  // Lưu token vào SharedPreferences
  static Future<void> saveAccessToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('accessToken', token);
  }

  // Lưu userAccountId vào SharedPreferences
  static Future<void> saveUserAccountId(int userAccountId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('userAccountId', userAccountId);
  }

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

  // Lưu userAccountId vào SharedPreferences
  static Future<int> getUserAccountId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('userAccountId') ?? 0; // Trả về 0 nếu không có
  }

  // Xóa dữ liệu người dùng khi đăng xuất
  static Future<void> clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('accessToken');
    await prefs.remove('userAccountId');
  }
}
