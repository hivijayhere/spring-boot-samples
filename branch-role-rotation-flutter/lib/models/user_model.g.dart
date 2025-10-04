// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
      id: (json['id'] as num).toInt(),
      employeeId: json['employeeId'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['firstName'] as String,
      lastName: json['lastName'] as String,
      branchCode: json['branchCode'] as String,
      branchName: json['branchName'] as String,
      isActive: json['isActive'] as bool,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
      'id': instance.id,
      'employeeId': instance.employeeId,
      'username': instance.username,
      'email': instance.email,
      'firstName': instance.firstName,
      'lastName': instance.lastName,
      'branchCode': instance.branchCode,
      'branchName': instance.branchName,
      'isActive': instance.isActive,
      'createdAt': instance.createdAt,
    };