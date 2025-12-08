class ButtonModel {
  final String name;
  final String type;
  final String? functionOnClick;

  ButtonModel({
    required this.name,
    required this.type,
    this.functionOnClick,
  });

  factory ButtonModel.fromJson(Map<String, dynamic> json) {
    return ButtonModel(
      name: json['name'] ?? '',
      type: json['type'] ?? '',
      functionOnClick: json['functionOnClick'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "type": type,
      "functionOnClick": functionOnClick,
    };
  }
}
