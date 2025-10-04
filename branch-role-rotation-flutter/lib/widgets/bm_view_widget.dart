import 'package:flutter/material.dart';
import '../models/bm_view_model.dart';
import '../widgets/job_role_card.dart';
import '../utils/app_constants.dart';

class BMViewWidget extends StatelessWidget {
  final BMViewModel bmView;

  const BMViewWidget({
    Key? key,
    required this.bmView,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // As on Date Display
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Row(
                children: [
                  const Icon(
                    Icons.calendar_today,
                    color: AppConstants.primaryColor,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    '${AppConstants.asOnDateTitle}: ',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                  Text(
                    bmView.asOnDate,
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppConstants.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          // My Job Role Details Section
          const Text(
            AppConstants.myJobRoleTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          
          if (bmView.myJobRoleDetails.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.defaultPadding),
                child: Center(
                  child: Text(
                    'No job role history found',
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          else
            ...bmView.myJobRoleDetails.map(
              (jobRole) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: JobRoleCard(
                  jobRole: jobRole,
                  showUserInfo: false,
                ),
              ),
            ),
          
          const SizedBox(height: 32),
          
          // My Team Job Role Details Section
          const Text(
            AppConstants.myTeamTitle,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppConstants.textPrimaryColor,
            ),
          ),
          const SizedBox(height: 12),
          
          if (bmView.myTeamJobRoleDetails.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.defaultPadding),
                child: Center(
                  child: Text(
                    'No team job role data found',
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          else
            ...bmView.myTeamJobRoleDetails.map(
              (jobRole) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: JobRoleCard(jobRole: jobRole),
              ),
            ),
        ],
      ),
    );
  }
}