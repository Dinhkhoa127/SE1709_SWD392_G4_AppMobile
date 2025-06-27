import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/changePassword.dart';
import 'dart:convert';
import '../services/api_service.dart';
import '../Helper/UserHelper.dart';

class UserProfileDetailScreen extends StatefulWidget {
  @override
  _UserProfileDetailScreenState createState() =>
      _UserProfileDetailScreenState();
}

class _UserProfileDetailScreenState extends State<UserProfileDetailScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers cho các text fields
  final TextEditingController _userNameController = TextEditingController();
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _employeeCodeController = TextEditingController();

  bool _isLoading = true;
  bool _isUpdating = false;
  int _userId = 0; // Giả sử userId là int, có thể thay đổi tùy theo API

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    _fullNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _employeeCodeController.dispose();
    super.dispose();
  }

  // Lấy thông tin user profile từ API
  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      // Lấy userId từ UserHelper hoặc từ tham số truyền vào
      _userId = await UserHelper.getUserAccountId(); // Giả sử có method này

      print('Loading user profile for ID: $_userId');

      // Gọi API để lấy thông tin user
      final response = await ApiService.getData(
        'user-accounts/$_userId',
      ); // Hoặc endpoint phù hợp

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        // Điền thông tin vào các controllers
        setState(() {
          _userNameController.text = userData['userName'] ?? '';
          _fullNameController.text = userData['fullName'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
        _showErrorDialog('Không thể tải thông tin người dùng');
      }
    } catch (error) {
      setState(() {
        _isLoading = false;
      });
      print('Load profile error: $error');
      _showErrorDialog('Có lỗi xảy ra khi tải thông tin');
    }
  }

  // Cập nhật thông tin user qua API
  Future<void> _updateUserProfile() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      setState(() {
        _isUpdating = true;
      });

      // Hiển thị loading dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => Center(child: CircularProgressIndicator()),
      );

      // Chuẩn bị data để gửi
      final updateData = {
        'userAccountId': _userId,
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      print('Updating user profile: $updateData');

      // Gọi API update
      final response = await ApiService.putData(
        'user-accounts/student/update-info',
        updateData,
      ); // Hoặc endpoint phù hợp

      // Ẩn loading dialog
      Navigator.of(context, rootNavigator: true).pop();

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        // Cập nhật thành công
        _showSuccessDialog('Cập nhật thông tin thành công!');
      } else {
        // Xử lý lỗi từ server
        try {
          final errorData = jsonDecode(response.body);
          String errorMessage = errorData['message'] ?? 'Cập nhật thất bại';
          _showErrorDialog(errorMessage);
        } catch (e) {
          _showErrorDialog('Lỗi server: ${response.statusCode}');
        }
      }
    } catch (error) {
      // Ẩn loading dialog nếu có lỗi
      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      print('Update profile error: $error');
      _showErrorDialog('Có lỗi xảy ra khi cập nhật thông tin');
    } finally {
      setState(() {
        _isUpdating = false;
      });
    }
  }

  // Validation cho email
  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  // Validation cho số điện thoại
  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
      return 'Số điện thoại phải có 10-11 chữ số';
    }
    return null;
  }

  // Hiển thị dialog lỗi
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Lỗi'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  // Hiển thị dialog thành công
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thành công'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop(); // Quay lại trang trước
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Thông tin cá nhân'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Avatar placeholder
                    Center(
                      child: Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.grey[300],
                        ),
                        child: Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.grey[600],
                        ),
                      ),
                    ),
                    SizedBox(height: 32),

                    // Tên người dùng
                    TextFormField(
                      controller: _userNameController,
                      decoration: InputDecoration(
                        labelText: 'Tên người dùng',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.account_circle),
                        fillColor: Colors.grey[100],
                        filled: true,
                      ),
                      readOnly: true, // Có thể không cho chỉnh sửa
                    ),
                    SizedBox(height: 16),

                    // Họ và tên
                    TextFormField(
                      controller: _fullNameController,
                      decoration: InputDecoration(
                        labelText: 'Họ và tên',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Họ và tên không được để trống';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 16),

                    // Email
                    TextFormField(
                      controller: _emailController,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.email),
                      ),
                      keyboardType: TextInputType.emailAddress,
                      validator: _validateEmail,
                    ),
                    SizedBox(height: 16),

                    // Số điện thoại
                    TextFormField(
                      controller: _phoneController,
                      decoration: InputDecoration(
                        labelText: 'Số điện thoại',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.phone),
                      ),
                      keyboardType: TextInputType.phone,
                      validator: _validatePhone,
                    ),
                    SizedBox(height: 16),

                    // Nút thay đổi mật khẩu (navigate to separate page)
                    OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to change password page
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ChangePasswordScreen(),
                          ),
                        );
                      },
                      icon: Icon(Icons.lock),
                      label: Text('Đổi mật khẩu'),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    // Nút cập nhật
                    ElevatedButton(
                      onPressed: _isUpdating ? null : _updateUserProfile,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: _isUpdating
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8),
                                Text('Đang cập nhật...'),
                              ],
                            )
                          : Text(
                              'Cập nhật thông tin',
                              style: TextStyle(fontSize: 16),
                            ),
                    ),

                    SizedBox(height: 16),

                    // Nút hủy
                    OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        padding: EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text('Hủy', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
