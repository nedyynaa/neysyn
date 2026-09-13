import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ArticleStorage {
  static const String _storageKey = 'saved_bookmarks_list';

  // Daftar artikel yang di-bookmark
  static List<Map<String, dynamic>> savedArticles = [];

  // Load bookmarks dari memori lokal HP/Browser
  static Future<void> loadSavedArticles() async {
    final prefs = await SharedPreferences.getInstance();
    final String? storedData = prefs.getString(_storageKey);
    if (storedData != null) {
      final List decoded = jsonDecode(storedData);
      savedArticles = decoded.map((item) => Map<String, dynamic>.from(item)).toList();
    }
  }

  // Cek apakah sebuah artikel sudah disimpen
  static bool isSaved(Map<String, dynamic> article) {
    final identifier = article['post_id'] ?? article['title'];
    return savedArticles.any((item) => (item['post_id'] ?? item['title']) == identifier);
  }

  // Toggle simpan/hapus bookmark lalu simpan permanen
  static Future<void> toggleSave(Map<String, dynamic> article) async {
    final identifier = article['post_id'] ?? article['title'];
    
    final index = savedArticles.indexWhere((item) => (item['post_id'] ?? item['title']) == identifier);

    if (index >= 0) {
      savedArticles.removeAt(index); // Hapus jika sudah ada (Unsave)
    } else {
      savedArticles.add(article); // Tambahkan jika belum ada (Save)
    }
    
    await _saveToPrefs();
  }

  // Helper simpan ke SharedPreferences
  static Future<void> _saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_storageKey, jsonEncode(savedArticles));
  }
}