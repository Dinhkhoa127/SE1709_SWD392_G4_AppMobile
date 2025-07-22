import 'package:flutter/material.dart';
import 'package:se1709_swd392_biologyrecognitionsystem_appmobile/services/api_service.dart';
import 'dart:convert';
import 'dart:async';
// THÊM IMPORT CHO LOGINSCREEN
import 'login.dart';

class ForgotPasswordScreen extends StatefulWidget {
  @override
  _ForgotPasswordScreenState createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  // State management
  int _currentStep = 1; // 1: Email, 2: OTP, 3: New Password
  bool _isLoading = false;
  String _userEmail = '';

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // API 1: GỬI OTP ĐẾN EMAIL - SỬA LỖI TYPE
  Future<void> _sendOTP() async {
    if (_emailController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng nhập email');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // SỬA LỖI: TRUYỀN EMAIL TRONG MAP THAY VÌ STRING TRỰC TIẾP
      final response = await ApiService.postData(
        'auth/otp/send/${_emailController.text.trim()}',
        {},
      );

      if (response.statusCode == 200) {
        setState(() {
          _userEmail = _emailController.text.trim();
          _currentStep = 2; // Chuyển sang bước nhập OTP
        });
        _showSuccessMessage('OTP đã được gửi đến email của bạn');
      } else {
        final data = jsonDecode(response.body);
        final errorMessage =
            data['message'] ?? 'Email không tồn tại hoặc có lỗi xảy ra';
        _showErrorMessage(errorMessage);
      }
    } catch (error) {
      _showErrorMessage('Lỗi kết nối: ${error.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // API 2: XÁC THỰC OTP - SỬ DỤNG ApiService
  Future<void> _verifyOTP() async {
    if (_otpController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng nhập mã OTP');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // SỬ DỤNG ApiService.postData
      final response = await ApiService.postData('auth/otp/verify', {
        "email": _userEmail,
        "otpCode": _otpController.text.trim(),
      });

      if (response.statusCode == 200) {
        setState(() {
          _currentStep = 3; // Chuyển sang bước đổi mật khẩu
        });
        _showSuccessMessage('OTP chính xác! Vui lòng nhập mật khẩu mới');
      } else {
        final data = jsonDecode(response.body);
        final errorMessage =
            data['message'] ?? 'Mã OTP không chính xác hoặc đã hết hạn';
        _showErrorMessage(errorMessage);
      }
    } catch (error) {
      _showErrorMessage('Lỗi kết nối: ${error.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // API 3: ĐẶT LẠI MẬT KHẨU - BỎ VALIDATION 6 KÝ TỰ, THÊM NAVIGATE VỀ LOGIN
  Future<void> _resetPassword() async {
    if (_newPasswordController.text.trim().isEmpty ||
        _confirmPasswordController.text.trim().isEmpty) {
      _showErrorMessage('Vui lòng nhập đầy đủ thông tin');
      return;
    }

    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showErrorMessage('Mật khẩu xác nhận không khớp');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // SỬ DỤNG ApiService.postData
      final response = await ApiService.postData('auth/otp/reset-password', {
        "email": _userEmail,
        "otpCode": _otpController.text.trim(),
        "newPassword": _newPasswordController.text.trim(),
      });

      if (response.statusCode == 200) {
        _showSuccessMessage('Đổi mật khẩu thành công!');

        // HIỂN THỊ DIALOG COUNTDOWN
        _showSuccessDialog();
      } else {
        final data = jsonDecode(response.body);
        final errorMessage =
            data['message'] ?? 'Có lỗi xảy ra khi đổi mật khẩu';
        _showErrorMessage(errorMessage);
      }
    } catch (error) {
      _showErrorMessage('Lỗi kết nối: ${error.toString()}');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Hiển thị thông báo lỗi
  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  // Hiển thị thông báo thành công
  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  // THÊM METHOD MỚI - DIALOG COUNTDOWN
  void _showSuccessDialog() {
    int countdown = 5;

    showDialog(
      context: context,
      barrierDismissible: false, // Không cho đóng dialog bằng tap outside
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            // Auto countdown
            Timer.periodic(Duration(seconds: 1), (timer) {
              if (countdown > 0) {
                setState(() {
                  countdown--;
                });
              } else {
                timer.cancel();
                Navigator.of(context).pop(); // Đóng dialog
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            });

            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // SUCCESS ICON
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.green,
                    ),
                    child: Icon(Icons.check, color: Colors.white, size: 50),
                  ),
                  SizedBox(height: 20),

                  // SUCCESS MESSAGE
                  Text(
                    'Đổi mật khẩu thành công!',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[700],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),

                  // COUNTDOWN TEXT
                  Text(
                    'Chuyển về trang đăng nhập sau $countdown giây',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),

                  // PROGRESS INDICATOR
                  LinearProgressIndicator(
                    value: (5 - countdown) / 5, // Progress từ 0 đến 1
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                  ),
                  SizedBox(height: 20),

                  // BUTTON ĐỂ SKIP COUNTDOWN
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(); // Đóng dialog
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => LoginScreen(),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        'Đăng nhập ngay',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Quên mật khẩu'),
        backgroundColor: Colors.orange,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // PROGRESS INDICATOR
              _buildProgressIndicator(),
              SizedBox(height: 30),

              // STEP CONTENT
              if (_currentStep == 1) _buildEmailStep(),
              if (_currentStep == 2) _buildOTPStep(),
              if (_currentStep == 3) _buildPasswordStep(),

              SizedBox(height: 30),

              // ACTION BUTTONS
              _buildActionButtons(),

              SizedBox(height: 20),

              // BACK TO LOGIN
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Quay lại đăng nhập',
                    style: TextStyle(color: Colors.blue),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // PROGRESS INDICATOR
  Widget _buildProgressIndicator() {
    return Column(
      children: [
        Row(
          children: [
            _buildStepCircle(1, 'Email'),
            Expanded(child: _buildStepLine(1)),
            _buildStepCircle(2, 'OTP'),
            Expanded(child: _buildStepLine(2)),
            _buildStepCircle(3, 'Mật khẩu'),
          ],
        ),
        SizedBox(height: 10),
        Text(
          _getStepTitle(),
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange[700],
          ),
        ),
      ],
    );
  }

  Widget _buildStepCircle(int step, String label) {
    bool isActive = step <= _currentStep;
    return Column(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isActive ? Colors.orange : Colors.grey[300],
          ),
          child: Center(
            child: Text(
              step.toString(),
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? Colors.orange[700] : Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStepLine(int step) {
    bool isActive = step < _currentStep;
    return Container(
      height: 2,
      color: isActive ? Colors.orange : Colors.grey[300],
      margin: EdgeInsets.only(bottom: 20),
    );
  }

  String _getStepTitle() {
    switch (_currentStep) {
      case 1:
        return 'Nhập email của bạn';
      case 2:
        return 'Nhập mã OTP';
      case 3:
        return 'Đặt mật khẩu mới';
      default:
        return '';
    }
  }

  // STEP 1: EMAIL INPUT
  Widget _buildEmailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhập địa chỉ email để nhận mã OTP:',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Email',
            hintText: 'example@gmail.com',
            prefixIcon: Icon(Icons.email, color: Colors.orange),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange),
            ),
          ),
        ),
      ],
    );
  }

  // STEP 2: OTP INPUT
  Widget _buildOTPStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nhập mã OTP đã được gửi đến:',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        SizedBox(height: 8),
        Text(
          _userEmail,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange[700],
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          decoration: InputDecoration(
            labelText: 'Mã OTP',
            hintText: '123456',
            prefixIcon: Icon(Icons.security, color: Colors.orange),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange),
            ),
          ),
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text(
              'Không nhận được mã? ',
              style: TextStyle(color: Colors.grey[600]),
            ),
            TextButton(
              onPressed: _isLoading ? null : _sendOTP,
              child: Text('Gửi lại', style: TextStyle(color: Colors.orange)),
            ),
          ],
        ),
      ],
    );
  }

  // STEP 3: NEW PASSWORD INPUT - BỎ HINT 6 KÝ TỰ
  Widget _buildPasswordStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Tạo mật khẩu mới cho tài khoản:',
          style: TextStyle(fontSize: 16, color: Colors.grey[700]),
        ),
        SizedBox(height: 8),
        Text(
          _userEmail,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.orange[700],
          ),
        ),
        SizedBox(height: 20),
        TextField(
          controller: _newPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Mật khẩu mới',
            hintText: 'Nhập mật khẩu mới', // ← BỎ HINT "Ít nhất 6 ký tự"
            prefixIcon: Icon(Icons.lock, color: Colors.orange),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange),
            ),
          ),
        ),
        SizedBox(height: 16),
        TextField(
          controller: _confirmPasswordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: 'Xác nhận mật khẩu',
            hintText: 'Nhập lại mật khẩu mới',
            prefixIcon: Icon(Icons.lock_outline, color: Colors.orange),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.orange),
            ),
          ),
        ),
      ],
    );
  }

  // ACTION BUTTONS
  Widget _buildActionButtons() {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 50,
          child: ElevatedButton(
            onPressed: _isLoading ? null : _getButtonAction(),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white)
                : Text(
                    _getButtonText(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
          ),
        ),
        if (_currentStep > 1) ...[
          SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 50,
            child: OutlinedButton(
              onPressed: _isLoading ? null : _goToPreviousStep,
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.orange),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Quay lại',
                style: TextStyle(fontSize: 16, color: Colors.orange),
              ),
            ),
          ),
        ],
      ],
    );
  }

  VoidCallback? _getButtonAction() {
    switch (_currentStep) {
      case 1:
        return _sendOTP;
      case 2:
        return _verifyOTP;
      case 3:
        return _resetPassword;
      default:
        return null;
    }
  }

  String _getButtonText() {
    switch (_currentStep) {
      case 1:
        return 'Gửi mã OTP';
      case 2:
        return 'Xác thực OTP';
      case 3:
        return 'Đổi mật khẩu';
      default:
        return '';
    }
  }

  void _goToPreviousStep() {
    setState(() {
      if (_currentStep > 1) {
        _currentStep--;
      }
    });
  }
}
