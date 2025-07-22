import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/Screens/changePassword.dart';
import 'dart:convert';
import '../services/api_service.dart';

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

  bool _isLoading = true;
  bool _isUpdating = false;
  int _userAccountId = 0;

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
    super.dispose();
  }

  // Lấy thông tin user profile từ API mới
  Future<void> _loadUserProfile() async {
    try {
      setState(() {
        _isLoading = true;
      });

      print('Loading current user profile...');

      final response = await ApiService.getData('auth/current-user');

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final userData = jsonDecode(response.body);

        setState(() {
          _userAccountId = userData['userAccountId'] ?? 0;
          _userNameController.text = userData['userName'] ?? '';
          _fullNameController.text = userData['fullName'] ?? '';
          _emailController.text = userData['email'] ?? '';
          _phoneController.text = userData['phone'] ?? '';
          _isLoading = false;
        });

        print('Loaded user data:');
        print('- UserAccountId: $_userAccountId');
        print('- Username: ${userData['userName']}');
        print('- FullName: ${userData['fullName']}');
        print('- Email: ${userData['email']}');
        print('- Phone: ${userData['phone']}');
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
        builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          content: Row(
            children: [
              CircularProgressIndicator(color: Color(0xFF4CAF50)),
              SizedBox(width: 20),
              Text('Đang cập nhật...'),
            ],
          ),
        ),
      );

      final updateData = {
        'userAccountId': _userAccountId,
        'fullName': _fullNameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      };

      print('Updating user profile: $updateData');

      final response = await ApiService.putData(
        'user-accounts/me/info',
        updateData,
      );

      if (Navigator.canPop(context)) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      print('Update response status: ${response.statusCode}');
      print('Update response body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 204) {
        _showSuccessDialog('Cập nhật thông tin thành công!');
      } else {
        try {
          final errorData = jsonDecode(response.body);
          String errorMessage = errorData['message'] ?? 'Cập nhật thất bại';
          _showErrorDialog(errorMessage);
        } catch (e) {
          _showErrorDialog('Lỗi server: ${response.statusCode}');
        }
      }
    } catch (error) {
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

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email không được để trống';
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
      return 'Email không đúng định dạng';
    }
    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Số điện thoại không được để trống';
    }
    if (!RegExp(r'^[0-9]{10,11}$').hasMatch(value)) {
      return 'Số điện thoại phải có 10-11 chữ số';
    }
    return null;
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red[600]),
            SizedBox(width: 8),
            Text('Lỗi', style: TextStyle(color: Color(0xFF2E7D32))),
          ],
        ),
        content: Text(message, style: TextStyle(color: Colors.grey[700])),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Color(0xFF4CAF50)),
            SizedBox(width: 8),
            Text('Thành công', style: TextStyle(color: Color(0xFF2E7D32))),
          ],
        ),
        content: Text(message, style: TextStyle(color: Colors.grey[700])),
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Color(0xFF4CAF50),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
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
        backgroundColor: Color(0xFF4CAF50),
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF4CAF50).withOpacity(0.1),
              Color(0xFF66BB6A).withOpacity(0.05),
              Colors.white,
            ],
            stops: [0.0, 0.3, 1.0],
          ),
        ),
        child: _isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Color(0xFF4CAF50)),
                    SizedBox(height: 16),
                    Text(
                      'Đang tải thông tin...',
                      style: TextStyle(
                        color: Color(0xFF2E7D32),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                padding: EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // PROFILE HEADER CARD
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // Avatar với gradient
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF4CAF50),
                                    Color(0xFF66BB6A),
                                  ],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Color(0xFF4CAF50).withOpacity(0.3),
                                    spreadRadius: 3,
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons.person,
                                size: 50,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Chỉnh sửa thông tin',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            SizedBox(height: 8),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Color(0xFF4CAF50).withOpacity(0.1),
                                    Color(0xFF66BB6A).withOpacity(0.1),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Color(0xFF4CAF50).withOpacity(0.3),
                                ),
                              ),
                              child: Text(
                                'Cập nhật thông tin cá nhân của bạn',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF2E7D32),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // FORM FIELDS CARD
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Thông tin chi tiết',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Tên người dùng (readonly)
                            _buildTextField(
                              controller: _userNameController,
                              label: 'Tên người dùng',
                              icon: Icons.account_circle,
                              readOnly: true,
                              fillColor: Colors.grey[50],
                            ),
                            SizedBox(height: 16),

                            // Họ và tên
                            _buildTextField(
                              controller: _fullNameController,
                              label: 'Họ và tên',
                              icon: Icons.person,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Họ và tên không được để trống';
                                }
                                return null;
                              },
                            ),
                            SizedBox(height: 16),

                            // Email
                            _buildTextField(
                              controller: _emailController,
                              label: 'Email',
                              icon: Icons.email,
                              keyboardType: TextInputType.emailAddress,
                              validator: _validateEmail,
                            ),
                            SizedBox(height: 16),

                            // Số điện thoại
                            _buildTextField(
                              controller: _phoneController,
                              label: 'Số điện thoại',
                              icon: Icons.phone,
                              keyboardType: TextInputType.phone,
                              validator: _validatePhone,
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 24),

                      // ACTIONS CARD
                      Container(
                        padding: EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 15,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Tùy chọn khác',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF2E7D32),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Nút thay đổi mật khẩu
                            _buildActionButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) =>
                                        ChangePasswordScreen(),
                                  ),
                                );
                              },
                              icon: Icons.lock_outline,
                              text: 'Đổi mật khẩu',
                              isOutlined: true,
                            ),
                            SizedBox(height: 16),

                            // Nút cập nhật
                            _buildActionButton(
                              onPressed: _isUpdating
                                  ? null
                                  : _updateUserProfile,
                              icon: _isUpdating ? null : Icons.save,
                              text: _isUpdating
                                  ? 'Đang cập nhật...'
                                  : 'Cập nhật thông tin',
                              isLoading: _isUpdating,
                            ),
                            SizedBox(height: 12),

                            // Nút hủy
                            _buildActionButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: Icons.close,
                              text: 'Hủy',
                              isOutlined: true,
                              color: Colors.grey[600],
                            ),
                          ],
                        ),
                      ),

                      SizedBox(height: 100), // Space for safe area
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
    bool readOnly = false,
    Color? fillColor,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Color(0xFF2E7D32)),
        prefixIcon: Icon(icon, color: Color(0xFF4CAF50)),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF4CAF50).withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF4CAF50), width: 2),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Color(0xFF4CAF50).withOpacity(0.3)),
        ),
        filled: true,
        fillColor: fillColor ?? Color(0xFF4CAF50).withOpacity(0.05),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      style: TextStyle(color: Color(0xFF2E7D32)),
      keyboardType: keyboardType,
      validator: validator,
      readOnly: readOnly,
    );
  }

  Widget _buildActionButton({
    required VoidCallback? onPressed,
    IconData? icon,
    required String text,
    bool isOutlined = false,
    bool isLoading = false,
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: isOutlined
          ? OutlinedButton.icon(
              onPressed: onPressed,
              icon: icon != null ? Icon(icon, size: 20) : SizedBox.shrink(),
              label: Text(text),
              style: OutlinedButton.styleFrom(
                foregroundColor: color ?? Color(0xFF4CAF50),
                side: BorderSide(color: color ?? Color(0xFF4CAF50)),
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            )
          : ElevatedButton(
              onPressed: onPressed,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF4CAF50),
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: isLoading
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
                        SizedBox(width: 12),
                        Text(text, style: TextStyle(fontSize: 16)),
                      ],
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, size: 20),
                          SizedBox(width: 8),
                        ],
                        Text(text, style: TextStyle(fontSize: 16)),
                      ],
                    ),
            ),
    );
  }
}
