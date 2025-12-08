import 'button_model.dart';
import 'child_model.dart';
import 'field_model.dart';

class FormModel {
  final String tableName;
  final String menuID;
  final List<FieldModel> fields;
  final List<ChildModel> child;
  final List<ButtonModel> buttons;

  FormModel({
    required this.tableName,
    required this.menuID,
    required this.fields,
    required this.child,
    required this.buttons,
  });

  factory FormModel.fromJson(Map<String, dynamic> json) {
    return FormModel(
      tableName: json['tableName'] ?? '',
      menuID: json['menuID'] ?? '',
      fields: (json['fields'] as List? ?? [])
          .map((e) => FieldModel.fromJson(e))
          .toList(),
      child: (json['child'] as List? ?? [])
          .map((e) => ChildModel.fromJson(e))
          .toList(),
      buttons: (json['buttons'] as List? ?? [])
          .map((e) => ButtonModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "tableName": tableName,
      "menuID": menuID,
      "fields": fields.map((e) => e.toJson()).toList(),
      "child": child.map((e) => e.toJson()).toList(),
      "buttons": buttons.map((e) => e.toJson()).toList(),
    };
  }
}
