import 'package:flutter/material.dart';
import '../main.dart'; // Import MainScreen
import '../widgets/auth_form.dart';
import '../services/api_service.dart';
import 'dart:convert';

class LoginScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AuthForm(
        title: 'Đăng nhập',
        fields: [
          AuthField(
            label: 'Email',
            keyName: 'userNameOrEmail',
            keyboardType: TextInputType.emailAddress,
          ),
          AuthField(label: 'Mật khẩu', keyName: 'password', isPassword: true),
        ],
        submitButtonText: 'Đăng nhập',
        onSubmit: (values) async {
          try {
            // Hiển thị loading indicator
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (context) => Center(child: CircularProgressIndicator()),
            );

            print("Đang gọi API đăng nhập...");
            // Gọi API login ở đây
            final response = await ApiService.postData('authentication/login', {
              'userNameOrEmail': values['userNameOrEmail'],
              'password': values['password'],
            });

            // Ẩn loading indicator
            Navigator.of(context, rootNavigator: true).pop();

            print("Trạng thái phản hồi: ${response.statusCode}");
            if (response.statusCode == 200) {
              print("Đăng nhập thành công");
              final data = jsonDecode(response.body);
              // Dùng pushReplacement thay vì push
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => MainScreen(initialIndex: 0),
                ),
              );
            } else {
              final data = jsonDecode(response.body);
              final errorMessage = data['message'] ?? 'Đăng nhập thất bại';
              print("Lỗi: $errorMessage");
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(errorMessage)));
            }
          } catch (e) {
            // Ẩn loading indicator nếu đang hiển thị
            Navigator.of(context, rootNavigator: true).pop();
            print("Exception: $e");
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Lỗi kết nối: ${e.toString()}')),
            );
          }
        },
        footer: TextButton(
          onPressed: () {
            // Chuyển sang màn hình đăng ký
          },
          child: Text('Chưa có tài khoản? Đăng ký'),
        ),
      ),
    );
  }
}
