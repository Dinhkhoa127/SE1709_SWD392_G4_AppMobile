import 'package:flutter/material.dart';
import '../Screens/login.dart';
import '../widgets/auth_form.dart';
import '../services/api_service.dart';
import 'dart:convert';

class RegisterScreen extends StatelessWidget {
  // Hàm kiểm tra password và confirmPassword có khớp nhau không
  bool _validatePasswordMatch(String password, String confirmPassword) {
    return password == confirmPassword;
  }

  // Hàm kiểm tra email có đúng định dạng không
  bool _validateEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  // Hàm kiểm tra số điện thoại
  bool _validatePhone(String phone) {
    return RegExp(r'^[0-9]{10,11}$').hasMatch(phone);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // THÊM resizeToAvoidBottomInset để tự động điều chỉnh khi có bàn phím
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: SingleChildScrollView(
          // THÊM padding để tránh keyboard overlay
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: AuthForm(
            title: 'Đăng ký',
            fields: [
              AuthField(label: 'Tên người dùng', keyName: 'userName'),
              AuthField(label: 'Họ và tên', keyName: 'fullName'),
              AuthField(
                label: 'Email',
                keyName: 'email',
                keyboardType: TextInputType.emailAddress,
              ),
              AuthField(
                label: 'Số điện thoại',
                keyName: 'phone',
                keyboardType: TextInputType.phone,
              ),
              AuthField(
                label: 'Mật khẩu',
                keyName: 'password',
                isPassword: true,
              ),
              AuthField(
                label: 'Xác nhận mật khẩu',
                keyName: 'confirmPassword',
                isPassword: true,
              ),
            ],
            submitButtonText: 'Đăng ký',
            onSubmit: (values) async {
              try {
                // Kiểm tra các trường bắt buộc
                if (values['userName']?.isEmpty ?? true) {
                  _showErrorDialog(context, 'Vui lòng nhập tên người dùng');
                  return;
                }

                if (values['fullName']?.isEmpty ?? true) {
                  _showErrorDialog(context, 'Vui lòng nhập họ và tên');
                  return;
                }

                if (values['email']?.isEmpty ?? true) {
                  _showErrorDialog(context, 'Vui lòng nhập email');
                  return;
                }

                if (!_validateEmail(values['email']!)) {
                  _showErrorDialog(context, 'Email không đúng định dạng');
                  return;
                }

                if (values['phone']?.isEmpty ?? true) {
                  _showErrorDialog(context, 'Vui lòng nhập số điện thoại');
                  return;
                }

                if (!_validatePhone(values['phone']!)) {
                  _showErrorDialog(
                    context,
                    'Số điện thoại phải có 10-11 chữ số',
                  );
                  return;
                }

                if (values['password']?.isEmpty ?? true) {
                  _showErrorDialog(context, 'Vui lòng nhập mật khẩu');
                  return;
                }

                if (values['confirmPassword']?.isEmpty ?? true) {
                  _showErrorDialog(context, 'Vui lòng xác nhận mật khẩu');
                  return;
                }

                // Kiểm tra password và confirmPassword có khớp nhau không
                if (!_validatePasswordMatch(
                  values['password']!,
                  values['confirmPassword']!,
                )) {
                  _showErrorDialog(context, 'Mật khẩu xác nhận không khớp');
                  return;
                }

                // Hiển thị loading indicator
                showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (context) =>
                      Center(child: CircularProgressIndicator()),
                );

                // Gọi API đăng ký với đúng các trường theo API documentation
                final response = await ApiService.postData(
                  'authentication/register',
                  {
                    'userName': values['userName'],
                    'password': values['password'],
                    'fullName': values['fullName'],
                    'email': values['email'],
                    'phone': values['phone'],
                    'roleId':
                        2, // Giả sử roleId là 2 cho người dùng bình thường
                  },
                );

                // Ẩn loading indicator
                Navigator.of(context, rootNavigator: true).pop();
                // Thêm debug logs chi tiết
                print('=== REGISTER RESPONSE DEBUG ===');
                print('Status Code: ${response.statusCode}');
                print('Headers: ${response.headers}');
                print('Response Body: ${response.body}');
                print(
                  'Request Data: ${jsonEncode({'userName': values['userName'], 'password': values['password'], 'fullName': values['fullName'], 'email': values['email'], 'phone': values['phone']})}',
                );
                print('===============================');

                if (response.statusCode == 200) {
                  // Hiển thị thông báo thành công
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text('Thành công'),
                      content: Text('Đăng ký tài khoản thành công!'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) => LoginScreen(),
                              ),
                            );
                          },
                          child: Text('OK'),
                        ),
                      ],
                    ),
                  );
                } else {
                  // Xử lý lỗi từ server
                  final errorData = jsonDecode(response.body);
                  String errorMessage =
                      errorData['message'] ?? 'Đăng ký thất bại';
                  _showErrorDialog(context, errorMessage);
                  // Xử lý lỗi từ server với debug chi tiết
                  print('=== ERROR RESPONSE ===');
                  print('Status: ${response.statusCode}');
                  print('Body: ${response.body}');
                  print('=====================');
                }
              } catch (error) {
                // Ẩn loading indicator nếu có lỗi
                Navigator.of(context, rootNavigator: true).pop();
                _showErrorDialog(context, 'Có lỗi xảy ra. Vui lòng thử lại.');
                print('Register error: $error'); // Debug log
              }
            },
            footer: TextButton(
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              },
              child: Text('Đã có tài khoản? Đăng nhập'),
            ),
          ),
        ),
      ),
    );
  }

  // Hàm helper để hiển thị dialog lỗi
  void _showErrorDialog(BuildContext context, String message) {
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
}
