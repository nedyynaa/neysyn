import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  static Future<List<dynamic>> fetchPosts() async {
    final response = await http.get(Uri.parse('$baseUrl/posts'));
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Gagal memuat artikel');
    }
  }

  static Future<void> createPost(
    String title,
    String content,
    XFile? imageFile,
  ) async {
    var request = http.MultipartRequest('POST', Uri.parse('$baseUrl/posts'));
    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['category_id'] = '1';

    if (imageFile != null) {
      if (kIsWeb) {
        var bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: imageFile.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 201) {
      throw Exception('Gagal menyimpan artikel');
    }
  }

  static Future<void> updatePost(
    int id,
    String title,
    String content,
    XFile? imageFile,
  ) async {
    var request = http.MultipartRequest('PUT', Uri.parse('$baseUrl/posts/$id'));
    request.fields['title'] = title;
    request.fields['content'] = content;
    request.fields['category_id'] = '1';

    if (imageFile != null) {
      if (kIsWeb) {
        var bytes = await imageFile.readAsBytes();
        request.files.add(
          http.MultipartFile.fromBytes(
            'image',
            bytes,
            filename: imageFile.name,
          ),
        );
      } else {
        request.files.add(
          await http.MultipartFile.fromPath('image', imageFile.path),
        );
      }
    }

    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);
    if (response.statusCode != 200) {
      throw Exception('Gagal memperbarui artikel');
    }
  }

  static Future<void> deletePost(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/posts/$id'));
    if (response.statusCode != 200) {
      throw Exception('Gagal menghapus artikel');
    }
  }
}
