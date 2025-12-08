import 'field_model.dart';

class ChildModel {
  final String tableName;
  final String childHeading;
  final List<FieldModel> fields;

  ChildModel({
    required this.tableName,
    required this.childHeading,
    required this.fields,
  });

  factory ChildModel.fromJson(Map<String, dynamic> json) {
    return ChildModel(
      tableName: json['tableName'] ?? '',
      childHeading: json['childHeading'] ?? '',
      fields: (json['fields'] as List? ?? [])
          .map((e) => FieldModel.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "tableName": tableName,
      "childHeading": childHeading,
      "fields": fields.map((e) => e.toJson()).toList(),
    };
  }
}
