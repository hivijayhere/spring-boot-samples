import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/job_role_provider.dart';
import '../utils/app_constants.dart';
import '../widgets/date_picker_widget.dart';
import '../widgets/job_role_card.dart';
import '../widgets/bm_view_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  String _selectedDate = '';

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().toIso8601String().split('T')[0];
    _tabController = TabController(length: 3, vsync: this);
    _loadInitialData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadInitialData() async {
    final jobRoleProvider = Provider.of<JobRoleProvider>(context, listen: false);
    await jobRoleProvider.loadMyJobRoleHistoryAsOnDate(_selectedDate);
    await jobRoleProvider.loadMyCurrentRole();
  }

  Future<void> _onDateChanged(String date) async {
    setState(() {
      _selectedDate = date;
    });
    
    final jobRoleProvider = Provider.of<JobRoleProvider>(context, listen: false);
    await jobRoleProvider.loadMyJobRoleHistoryAsOnDate(date);
  }

  Future<void> _refreshData() async {
    final jobRoleProvider = Provider.of<JobRoleProvider>(context, listen: false);
    await jobRoleProvider.loadMyJobRoleHistoryAsOnDate(_selectedDate);
    await jobRoleProvider.loadMyCurrentRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppConstants.homeTitle),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'logout') {
                final authProvider = Provider.of<AuthProvider>(context, listen: false);
                await authProvider.logout();
                if (mounted) {
                  Navigator.pushReplacementNamed(context, '/login');
                }
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout),
                    SizedBox(width: 8),
                    Text('Logout'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person), text: 'My Role'),
            Tab(icon: Icon(Icons.group), text: 'Team'),
            Tab(icon: Icon(Icons.business), text: 'Branch'),
          ],
        ),
      ),
      body: Consumer2<AuthProvider, JobRoleProvider>(
        builder: (context, authProvider, jobRoleProvider, child) {
          if (jobRoleProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          return Column(
            children: [
              // As on Date Widget
              DatePickerWidget(
                selectedDate: _selectedDate,
                onDateChanged: _onDateChanged,
              ),
              
              // Error Display
              if (jobRoleProvider.error != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(AppConstants.defaultPadding),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppConstants.errorColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppConstants.borderRadius),
                    border: Border.all(color: AppConstants.errorColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    jobRoleProvider.error!,
                    style: const TextStyle(
                      color: AppConstants.errorColor,
                      fontSize: 14,
                    ),
                  ),
                ),
              
              // Tab Content
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    // My Role Tab
                    _buildMyRoleTab(authProvider.user, jobRoleProvider),
                    
                    // Team Tab
                    _buildTeamTab(authProvider.user, jobRoleProvider),
                    
                    // Branch Tab
                    _buildBranchTab(authProvider.user, jobRoleProvider),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildMyRoleTab(user, JobRoleProvider jobRoleProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (user != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'User Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow('Employee ID', user.employeeId),
                    _buildInfoRow('Name', user.fullName),
                    _buildInfoRow('Branch', '${user.branchCode} - ${user.branchName}'),
                    _buildInfoRow('Email', user.email),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          if (jobRoleProvider.currentRole != null) ...[
            const Text(
              'Current Role',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            JobRoleCard(
              jobRole: jobRoleProvider.currentRole!,
              showUserInfo: false,
            ),
            const SizedBox(height: 24),
          ],
          
          const Text(
            'Job Role History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          if (jobRoleProvider.myJobRoleHistory.isEmpty)
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
            ...jobRoleProvider.myJobRoleHistory.map(
              (jobRole) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: JobRoleCard(jobRole: jobRole),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamTab(user, JobRoleProvider jobRoleProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Team Job Role Details',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          ElevatedButton.icon(
            onPressed: () async {
              await jobRoleProvider.loadTeamJobRoleHistory(_selectedDate);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Load Team Data'),
          ),
          const SizedBox(height: 16),
          
          if (jobRoleProvider.teamJobRoleHistory.isEmpty)
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
            ...jobRoleProvider.teamJobRoleHistory.map(
              (jobRole) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: JobRoleCard(jobRole: jobRole),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBranchTab(user, JobRoleProvider jobRoleProvider) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Branch Job Role History',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          
          ElevatedButton.icon(
            onPressed: () async {
              await jobRoleProvider.loadBranchJobRoleHistory(_selectedDate);
            },
            icon: const Icon(Icons.refresh),
            label: const Text('Load Branch Data'),
          ),
          const SizedBox(height: 16),
          
          if (jobRoleProvider.branchJobRoleHistory.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(AppConstants.defaultPadding),
                child: Center(
                  child: Text(
                    'No branch job role data found',
                    style: TextStyle(
                      color: AppConstants.textSecondaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            )
          else
            ...jobRoleProvider.branchJobRoleHistory.map(
              (jobRole) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: JobRoleCard(jobRole: jobRole),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppConstants.textSecondaryColor,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                color: AppConstants.textPrimaryColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}