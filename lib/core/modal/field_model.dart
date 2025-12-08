class FieldModel {
  final String fieldname;
  final String yourlabel;
  final String controlname;
  final String type;
  final bool isRequired;
  final String? sectionHeader;
  final int? sectionOrder;
  final List<dynamic> dropDownValues;
  final Map<String, dynamic>? raw;

  FieldModel({
    required this.fieldname,
    required this.yourlabel,
    required this.controlname,
    required this.type,
    required this.isRequired,
    this.sectionHeader,
    this.sectionOrder,
    this.dropDownValues = const [],
    this.raw,
  });

  factory FieldModel.fromJson(Map<String, dynamic> json) {
    return FieldModel(
      fieldname: json['fieldname'] ?? '',
      yourlabel: json['yourlabel'] ?? '',
      controlname: json['controlname'] ?? 'text',
      type: json['type'] ?? 'string',
      isRequired: json['isRequired'] ?? false,
      sectionHeader: json['sectionHeader'],
      sectionOrder: json['sectionOrder'],
      dropDownValues: List.from(json['dropDownValues'] ?? []),
      raw: json,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "fieldname": fieldname,
      "yourlabel": yourlabel,
      "controlname": controlname,
      "type": type,
      "isRequired": isRequired,
      "sectionHeader": sectionHeader,
      "sectionOrder": sectionOrder,
      "dropDownValues": dropDownValues,
    };
  }
}
