import 'package:json_annotation/json_annotation.dart';

part 'job_role_rotation_model.g.dart';

@JsonSerializable()
class JobRoleRotationModel {
  final int id;
  final int userId;
  final String userFullName;
  final String employeeId;
  final int jobRoleId;
  final String roleCode;
  final String roleName;
  final String roleType;
  final String branchCode;
  final String branchName;
  final String effectiveFrom;
  final String? effectiveTo;
  final bool isCurrent;
  final String? createdBy;
  final String createdAt;

  JobRoleRotationModel({
    required this.id,
    required this.userId,
    required this.userFullName,
    required this.employeeId,
    required this.jobRoleId,
    required this.roleCode,
    required this.roleName,
    required this.roleType,
    required this.branchCode,
    required this.branchName,
    required this.effectiveFrom,
    this.effectiveTo,
    required this.isCurrent,
    this.createdBy,
    required this.createdAt,
  });

  factory JobRoleRotationModel.fromJson(Map<String, dynamic> json) => 
      _$JobRoleRotationModelFromJson(json);
  Map<String, dynamic> toJson() => _$JobRoleRotationModelToJson(this);
}