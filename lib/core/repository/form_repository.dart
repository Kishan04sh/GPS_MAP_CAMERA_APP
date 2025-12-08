//
// import 'dart:convert';
// import 'package:flutter/services.dart';
// import '../modal/form_model.dart';
// import '../storege/local_json_storage.dart';
//
// class FormRepository {
//   // load (if local copy exists use it otherwise copy from assets)
//   Future<FormModel> loadFormModel() async {
//     final localFile = await LocalJsonStorage.getLocalFile();
//
//     if (await localFile.exists()) {
//       final raw = await localFile.readAsString();
//       final parsed = jsonDecode(raw);
//       return FormModel.fromJson(parsed as Map<String, dynamic>);
//     } else {
//       final raw = await rootBundle.loadString('assets/json/Assingment_JSON.json');
//       final parsedList = jsonDecode(raw) as List;
//       if (parsedList.isEmpty) throw Exception('form JSON empty');
//       final Map<String, dynamic> parsed = parsedList[0] as Map<String, dynamic>;
//
//       // write to local
//       await localFile.writeAsString(jsonEncode(parsed));
//       return FormModel.fromJson(parsed);
//     }
//   }
//
//   /// Overwrite local JSON file with new JSON object
//   Future<void> writeLocalJson(Map<String, dynamic> json) async {
//     final localFile = await LocalJsonStorage.getLocalFile();
//     await localFile.writeAsString(jsonEncode(json));
//   }
// }


import 'dart:convert';
import 'package:flutter/services.dart';
import '../modal/form_model.dart';
import '../storege/local_json_storage.dart'; // <- SharedPreferences version

class FormRepository {
  Future<FormModel> loadFormModel() async {
    final savedJson = await LocalFormStorage.load();

    if (savedJson != null) {
      print("📥 Loaded JSON from SharedPreferences: ${jsonEncode(savedJson)}");
      return FormModel.fromJson(savedJson);
    } else {
      final raw = await rootBundle.loadString('assets/json/Assingment_JSON.json');
      final parsedList = jsonDecode(raw) as List;
      if (parsedList.isEmpty) throw Exception('form JSON empty');
      final Map<String, dynamic> parsed = parsedList[0] as Map<String, dynamic>;

      // write to local (SharedPreferences)
      await LocalFormStorage.save(parsed);
      print("✅ Saved initial JSON to SharedPreferences: ${jsonEncode(parsed)}");
      return FormModel.fromJson(parsed);
    }
  }

  /// Save/update JSON
  Future<void> writeLocalJson(Map<String, dynamic> json) async {
    await LocalFormStorage.save(json);
    print("💾 Saved JSON to SharedPreferences: ${jsonEncode(json)}");

    // Optional: verify immediately
    final loaded = await LocalFormStorage.load();
    print("📂 Verified Loaded JSON: ${jsonEncode(loaded)}");
  }
}
