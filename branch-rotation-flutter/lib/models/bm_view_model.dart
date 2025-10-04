import 'package:json_annotation/json_annotation.dart';
import 'job_role_rotation_model.dart';

part 'bm_view_model.g.dart';

@JsonSerializable()
class BMViewModel {
  final List<JobRoleRotationModel> myJobRoleDetails;
  final List<JobRoleRotationModel> myTeamJobRoleDetails;
  final String asOnDate;

  BMViewModel({
    required this.myJobRoleDetails,
    required this.myTeamJobRoleDetails,
    required this.asOnDate,
  });

  factory BMViewModel.fromJson(Map<String, dynamic> json) => _$BMViewModelFromJson(json);
  Map<String, dynamic> toJson() => _$BMViewModelToJson(this);
}