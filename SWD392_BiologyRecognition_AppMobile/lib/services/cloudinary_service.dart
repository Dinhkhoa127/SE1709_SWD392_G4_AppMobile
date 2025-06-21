import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/cloudinary_config.dart';

class CloudinaryService {
  static Future<String?> uploadImage(File imageFile) async {
    try {
      // Kiểm tra file có tồn tại không
      if (!await imageFile.exists()) {
        print('Error: Image file does not exist');
        return null;
      }

      // Kiểm tra cấu hình Cloudinary
      if (CloudinaryConfig.cloudName.isEmpty || 
          CloudinaryConfig.uploadPreset.isEmpty) {
        print('Error: Cloudinary configuration is missing');
        print('Cloud Name: ${CloudinaryConfig.cloudName}');
        print('Upload Preset: ${CloudinaryConfig.uploadPreset}');
        return null;
      }

      final url = Uri.parse(
        'https://api.cloudinary.com/v1_1/${CloudinaryConfig.cloudName}/image/upload',
      );

      print('Uploading to: $url');
      print('Upload preset: ${CloudinaryConfig.uploadPreset}');
      print('File path: ${imageFile.path}');

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = CloudinaryConfig.uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

      final response = await request.send();
      print('Response status code: ${response.statusCode}');

      if (response.statusCode == 200) {
        final resStr = await response.stream.bytesToString();
        print('Response body: $resStr');
        final resJson = json.decode(resStr);
        return resJson['secure_url'];
      } else {
        final errorResponse = await response.stream.bytesToString();
        print('Upload failed with status: ${response.statusCode}');
        print('Error response: $errorResponse');
        return null;
      }
    } catch (e) {
      print('Exception during upload: $e');
      return null;
    }
  }
}
