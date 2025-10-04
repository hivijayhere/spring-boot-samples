import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final int id;
  final String employeeId;
  final String username;
  final String email;
  final String firstName;
  final String lastName;
  final String branchCode;
  final String branchName;
  final bool isActive;
  final String createdAt;

  UserModel({
    required this.id,
    required this.employeeId,
    required this.username,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.branchCode,
    required this.branchName,
    required this.isActive,
    required this.createdAt,
  });

  String get fullName => '$firstName $lastName';

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}