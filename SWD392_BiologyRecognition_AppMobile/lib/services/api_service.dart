import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../config/api_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // GET
  static Future<http.Response> getData(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
    // Lấy token nếu có
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    // Chỉ thêm Authorization header khi token tồn tại
    final authHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final client = _createHttpClient();
    return await client.get(url, headers: authHeaders);
  }

  // POST
  static http.Client _createHttpClient() {
    HttpClient client = HttpClient()
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
    return IOClient(client);
  }

  static Future<http.Response> postData(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    try {
      final url = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
      //Lay token từ SharedPreferences nếu có
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken');
      // Chỉ thêm Authorization header khi token tồn tại
      final authHeaders = {
        'Content-Type': 'application/json',
        if (token != null)
          'Authorization':
              'Bearer $token', // Dòng này chỉ thêm header khi token tồn tại
        ...?headers,
      };
      final client = _createHttpClient();
      return await client.post(
        url,
        headers: authHeaders,
        body: jsonEncode(data),
      );
    } catch (e) {
      print("Lỗi API: $e");
      rethrow;
    }
  }

  // PUT
  static Future<http.Response> putData(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
    // Lấy token nếu có
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    // Chỉ thêm Authorization header khi token tồn tại
    final authHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final client = _createHttpClient();
    return await client.put(url, headers: authHeaders, body: jsonEncode(data));
  }

  // DELETE
  static Future<http.Response> deleteData(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
    // Lấy token nếu có
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('accessToken');

    // Chỉ thêm Authorization header khi token tồn tại
    final authHeaders = {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };

    final client = _createHttpClient();
    return await client.delete(url, headers: authHeaders);
  }
}
