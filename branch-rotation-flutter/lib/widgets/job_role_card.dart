import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/job_role_rotation_model.dart';
import '../utils/app_constants.dart';

class JobRoleCard extends StatelessWidget {
  final JobRoleRotationModel jobRole;
  final bool showUserInfo;

  const JobRoleCard({
    Key? key,
    required this.jobRole,
    this.showUserInfo = true,
  }) : super(key: key);

  Color _getRoleTypeColor(String roleType) {
    switch (roleType) {
      case 'BM':
        return AppConstants.primaryColor;
      case 'BDO':
        return AppConstants.successColor;
      case 'CSE':
        return AppConstants.warningColor;
      default:
        return AppConstants.textSecondaryColor;
    }
  }

  IconData _getRoleTypeIcon(String roleType) {
    switch (roleType) {
      case 'BM':
        return Icons.supervisor_account;
      case 'BDO':
        return Icons.trending_up;
      case 'CSE':
        return Icons.support_agent;
      default:
        return Icons.person;
    }
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return DateFormat('MMM dd, yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: AppConstants.cardElevation,
      child: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with Role Type Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: _getRoleTypeColor(jobRole.roleType).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(
                      color: _getRoleTypeColor(jobRole.roleType).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        _getRoleTypeIcon(jobRole.roleType),
                        size: 16,
                        color: _getRoleTypeColor(jobRole.roleType),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        jobRole.roleType,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: _getRoleTypeColor(jobRole.roleType),
                        ),
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                if (jobRole.isCurrent)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppConstants.successColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    ),
                    child: const Text(
                      'CURRENT',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: AppConstants.successColor,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Role Information
            Text(
              jobRole.roleName,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppConstants.textPrimaryColor,
              ),
            ),
            
            const SizedBox(height: 4),
            
            Text(
              'Code: ${jobRole.roleCode}',
              style: const TextStyle(
                fontSize: 14,
                color: AppConstants.textSecondaryColor,
              ),
            ),
            
            if (showUserInfo) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              
              // User Information
              Row(
                children: [
                  const Icon(
                    Icons.person,
                    size: 16,
                    color: AppConstants.textSecondaryColor,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          jobRole.userFullName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: AppConstants.textPrimaryColor,
                          ),
                        ),
                        Text(
                          'ID: ${jobRole.employeeId}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppConstants.textSecondaryColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
            
            const SizedBox(height: 12),
            
            // Branch Information
            Row(
              children: [
                const Icon(
                  Icons.business,
                  size: 16,
                  color: AppConstants.textSecondaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        jobRole.branchName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      Text(
                        'Code: ${jobRole.branchCode}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppConstants.textSecondaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Date Information
            Row(
              children: [
                const Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppConstants.textSecondaryColor,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'From: ${_formatDate(jobRole.effectiveFrom)}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppConstants.textPrimaryColor,
                        ),
                      ),
                      if (jobRole.effectiveTo != null)
                        Text(
                          'To: ${_formatDate(jobRole.effectiveTo!)}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppConstants.textPrimaryColor,
                          ),
                        )
                      else
                        const Text(
                          'To: Present',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppConstants.successColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (jobRole.createdBy != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(
                    Icons.person_add,
                    size: 16,
                    color: AppConstants.textSecondaryColor,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Created by: ${jobRole.createdBy}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppConstants.textSecondaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}