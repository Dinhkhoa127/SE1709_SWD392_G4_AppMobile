import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';
import '../config/api_config.dart';

class ApiService {
  // GET
  static Future<http.Response> getData(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
    return await http.get(url, headers: headers);
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

      final client = _createHttpClient();
      return await client.post(
        url,
        headers: {'Content-Type': 'application/json', ...?headers},
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
    return await http.put(
      url,
      headers: {'Content-Type': 'application/json', ...?headers},
      body: jsonEncode(data),
    );
  }

  // DELETE
  static Future<http.Response> deleteData(
    String endpoint, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
    return await http.delete(url, headers: headers);
  }
}
