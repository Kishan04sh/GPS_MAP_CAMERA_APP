import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalJsonStorage {
  static Future<File> getLocalFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/dynamic_form.json');
  }

  /// Check if local copy exists
  static Future<bool> exists() async {
    final f = await getLocalFile();
    return f.exists();
  }
}



/// *******************************************************


class LocalFormStorage {
  static const _key = "dynamic_form";

  /// Save JSON to SharedPreferences
  static Future<void> save(Map<String, dynamic> json) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(json));
  }

  /// Load JSON from SharedPreferences
  static Future<Map<String, dynamic>?> load() async {
    final prefs = await SharedPreferences.getInstance();
    final str = prefs.getString(_key);
    if (str == null) return null;
    return jsonDecode(str);
  }

  /// Clear JSON
  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
