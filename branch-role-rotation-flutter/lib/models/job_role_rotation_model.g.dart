// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_role_rotation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobRoleRotationModel _$JobRoleRotationModelFromJson(Map<String, dynamic> json) =>
    JobRoleRotationModel(
      id: (json['id'] as num).toInt(),
      userId: (json['userId'] as num).toInt(),
      userFullName: json['userFullName'] as String,
      employeeId: json['employeeId'] as String,
      jobRoleId: (json['jobRoleId'] as num).toInt(),
      roleCode: json['roleCode'] as String,
      roleName: json['roleName'] as String,
      roleType: json['roleType'] as String,
      branchCode: json['branchCode'] as String,
      branchName: json['branchName'] as String,
      effectiveFrom: json['effectiveFrom'] as String,
      effectiveTo: json['effectiveTo'] as String?,
      isCurrent: json['isCurrent'] as bool,
      createdBy: json['createdBy'] as String?,
      createdAt: json['createdAt'] as String,
    );

Map<String, dynamic> _$JobRoleRotationModelToJson(JobRoleRotationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'userFullName': instance.userFullName,
      'employeeId': instance.employeeId,
      'jobRoleId': instance.jobRoleId,
      'roleCode': instance.roleCode,
      'roleName': instance.roleName,
      'roleType': instance.roleType,
      'branchCode': instance.branchCode,
      'branchName': instance.branchName,
      'effectiveFrom': instance.effectiveFrom,
      'effectiveTo': instance.effectiveTo,
      'isCurrent': instance.isCurrent,
      'createdBy': instance.createdBy,
      'createdAt': instance.createdAt,
    };