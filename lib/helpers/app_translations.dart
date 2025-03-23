import 'package:flutter/services.dart';
import 'dart:convert';

class AppTranslations {
  static late Map<String, dynamic> _translations;

  static Future<void> load(String path) async {
    String jsonString = await rootBundle.loadString(path);
    _translations = json.decode(jsonString);
  }

  static Future<void> reload(String path)async{
    _translations.clear();
    await load(path);
  }

  static String get(String key) {
    if (_translations == null) {
      throw Exception('Translations not loaded. Call load() first.');
    }
    return _translations[key]?.toString() ?? '$key not found';
  }
}