import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/job_execution_provider.dart';
import '../widgets/job_status_card.dart';

class JobMonitoringScreen extends StatefulWidget {
  const JobMonitoringScreen({super.key});

  @override
  State<JobMonitoringScreen> createState() => _JobMonitoringScreenState();
}

class _JobMonitoringScreenState extends State<JobMonitoringScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<JobExecutionProvider>().loadRunningJobs();
      context.read<JobExecutionProvider>().loadJobHistory();
      context.read<JobExecutionProvider>().loadJobStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Monitoring'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<JobExecutionProvider>().loadRunningJobs();
              context.read<JobExecutionProvider>().loadJobHistory();
              context.read<JobExecutionProvider>().loadJobStats();
            },
          ),
        ],
      ),
      body: Consumer<JobExecutionProvider>(
        builder: (context, jobProvider, child) {
          if (jobProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (jobProvider.error != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Error: ${jobProvider.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      jobProvider.clearError();
                      jobProvider.loadRunningJobs();
                      jobProvider.loadJobHistory();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return DefaultTabController(
            length: 2,
            child: Column(
              children: [
                const TabBar(
                  tabs: [
                    Tab(text: 'Running Jobs'),
                    Tab(text: 'Job History'),
                  ],
                ),
                Expanded(
                  child: TabBarView(
                    children: [
                      _buildRunningJobsTab(jobProvider),
                      _buildJobHistoryTab(jobProvider),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildRunningJobsTab(JobExecutionProvider jobProvider) {
    final runningJobs = jobProvider.runningJobs;
    
    if (runningJobs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.play_circle_outline,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No running jobs',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: runningJobs.length,
      itemBuilder: (context, index) {
        final job = runningJobs[index];
        return JobStatusCard(job: job);
      },
    );
  }

  Widget _buildJobHistoryTab(JobExecutionProvider jobProvider) {
    final jobHistory = jobProvider.jobHistory;
    
    if (jobHistory.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No job history found',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: jobHistory.length,
      itemBuilder: (context, index) {
        final job = jobHistory[index];
        return JobStatusCard(job: job);
      },
    );
  }
}