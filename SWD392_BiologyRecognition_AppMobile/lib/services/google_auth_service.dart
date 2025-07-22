import 'package:google_sign_in/google_sign_in.dart';
import 'dart:convert';
import 'api_service.dart';
import '../Helper/UserHelper.dart';

class GoogleAuthService {
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  // Đăng nhập Google KHÔNG dùng Firebase
  static Future<bool> signInWithGoogle() async {
    try {
      print('🔍 [DEBUG] Starting Google Sign-In process...');

      // Đăng xuất trước để có thể chọn account khác
      await _googleSignIn.signOut();
      print('✅ [DEBUG] Signed out from previous session');

      // Bắt đầu Google Sign-In
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        print('❌ [DEBUG] User cancelled Google Sign-In');
        return false;
      }

      print('✅ [DEBUG] Google user signed in successfully');
      print('📧 [DEBUG] Email: ${googleUser.email}');
      print('👤 [DEBUG] Display Name: ${googleUser.displayName}');
      print('🆔 [DEBUG] User ID: ${googleUser.id}');

      // Lấy authentication details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      print('🔑 [DEBUG] Got Google authentication details');
      print('🔑 [DEBUG] ID Token: ${googleAuth.idToken?.substring(0, 20)}...');

      // Gửi Google ID Token trực tiếp đến backend
      if (googleAuth.idToken != null) {
        // Mock authentication cho test
        print('🧪 [DEBUG] Using mock authentication (bypassing backend)');
        await UserHelper.saveAccessToken(
          'mock_token_${DateTime.now().millisecondsSinceEpoch}',
        );
        await UserHelper.saveUserName(googleUser.displayName ?? 'Google User');
        await UserHelper.saveUserAccountId(googleUser.id.hashCode);
        print('💾 [DEBUG] Saved user data locally');
        print('🎉 [DEBUG] Google Sign-In completed successfully!');
        return true;

        // Uncomment khi backend ready
        /*
        final response = await ApiService.getData(
          'api/authentication/login-google?idToken=${googleAuth.idToken}'
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          
          await UserHelper.saveAccessToken(data['accessToken']);
          await UserHelper.saveUserName(data['userName']);
          await UserHelper.saveUserAccountId(data['userAccountId']);
          
          print('🎉 [DEBUG] Google login successful!');
          return true;
        } else {
          print('❌ [DEBUG] Backend authentication failed: ${response.body}');
          return false;
        }
        */
      }

      return false;
    } catch (error) {
      print('❌ [DEBUG] Google Sign-In error: $error');
      return false;
    }
  }

  // Đăng xuất Google
  static Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      print('✅ [DEBUG] Google Sign-Out successful');
    } catch (error) {
      print('❌ [DEBUG] Google Sign-Out error: $error');
    }
  }
}
