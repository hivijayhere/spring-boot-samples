// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'bm_view_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BMViewModel _$BMViewModelFromJson(Map<String, dynamic> json) => BMViewModel(
      myJobRoleDetails: (json['myJobRoleDetails'] as List<dynamic>)
          .map((e) => JobRoleRotationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      myTeamJobRoleDetails: (json['myTeamJobRoleDetails'] as List<dynamic>)
          .map((e) => JobRoleRotationModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      asOnDate: json['asOnDate'] as String,
    );

Map<String, dynamic> _$BMViewModelToJson(BMViewModel instance) =>
    <String, dynamic>{
      'myJobRoleDetails': instance.myJobRoleDetails,
      'myTeamJobRoleDetails': instance.myTeamJobRoleDetails,
      'asOnDate': instance.asOnDate,
    };