import 'package:intl/intl.dart';

class AuthUser {
  final String uid;
  final String? name;
  final String? email;
  final String? photo;

  AuthUser({
    required this.uid,
    this.name,
    this.email,
    this.photo,
  });
}


///================UserModel==================================================


class UserModel {
  final int id;
  final String phone;
  final String fireBaseId;
  final String name;
  final String email;
  final String dateTime;
  final String city;
  final String profession;
  final String pincode;
  final bool register; // ✅ better as bool

  UserModel({
    required this.id,
    required this.phone,
    required this.fireBaseId,
    required this.name,
    required this.email,
    required this.dateTime,
    required this.city,
    required this.profession,
    required this.pincode,
    required this.register,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: int.tryParse(json['id'].toString()) ?? 0,
      phone: json['phone']?.toString() ?? '',
      fireBaseId: json['fireBaseId']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      dateTime: json['dateTime']?.toString() ?? '',
      city: json['city']?.toString() ?? '',
      profession: json['profession']?.toString() ?? '',
      pincode: json['pincode']?.toString() ?? '',
      register: json['register']?.toString().toLowerCase() == 'true',
    );
  }

  /// ✅ formatted date (DD-MM-YYYY)
  String get formattedDate {
    try {
      final date = DateTime.parse(dateTime);
      return DateFormat('dd-MM-yyyy').format(date);
    } catch (e) {
      return dateTime; // fallback if parsing fails
    }
  }
}