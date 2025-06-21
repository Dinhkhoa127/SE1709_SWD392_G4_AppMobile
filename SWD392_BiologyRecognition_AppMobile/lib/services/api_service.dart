import 'dart:convert';
import 'package:http/http.dart' as http;
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
  static Future<http.Response> postData(
    String endpoint,
    Map<String, dynamic> data, {
    Map<String, String>? headers,
  }) async {
    final url = Uri.parse('${ApiConfig.baseUrl}/$endpoint');
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json', ...?headers},
      body: jsonEncode(data),
    );
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
