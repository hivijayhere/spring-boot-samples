import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../providers/table_config_provider.dart';
import '../providers/job_execution_provider.dart';
import '../providers/metrics_provider.dart';
import '../widgets/metrics_card.dart';
import '../widgets/job_status_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TableConfigProvider>().loadTableConfigs();
      context.read<JobExecutionProvider>().loadRunningJobs();
      context.read<JobExecutionProvider>().loadJobStats();
      context.read<MetricsProvider>().loadSystemMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TableConfigProvider>().loadTableConfigs();
              context.read<JobExecutionProvider>().loadRunningJobs();
              context.read<JobExecutionProvider>().loadJobStats();
              context.read<MetricsProvider>().loadSystemMetrics();
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // System Overview Cards
            Consumer<MetricsProvider>(
              builder: (context, metricsProvider, child) {
                if (metricsProvider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                final stats = metricsProvider.systemMetrics;
                return Row(
                  children: [
                    Expanded(
                      child: MetricsCard(
                        title: 'Total Tables',
                        value: '${stats['totalTables'] ?? 0}',
                        icon: Icons.table_chart,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MetricsCard(
                        title: 'Active Jobs',
                        value: '${stats['activeJobs'] ?? 0}',
                        icon: Icons.play_circle,
                        color: Colors.orange,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MetricsCard(
                        title: 'Completed Jobs',
                        value: '${stats['completedJobs'] ?? 0}',
                        icon: Icons.check_circle,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MetricsCard(
                        title: 'Failed Jobs',
                        value: '${stats['failedJobs'] ?? 0}',
                        icon: Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Data Processing Metrics
            Consumer<MetricsProvider>(
              builder: (context, metricsProvider, child) {
                final stats = metricsProvider.systemMetrics;
                return Row(
                  children: [
                    Expanded(
                      child: MetricsCard(
                        title: 'Records Archived',
                        value: '${stats['totalArchived'] ?? 0}',
                        icon: Icons.archive,
                        color: Colors.purple,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MetricsCard(
                        title: 'Records Purged',
                        value: '${stats['totalPurged'] ?? 0}',
                        icon: Icons.delete_forever,
                        color: Colors.red,
                      ),
                    ),
                  ],
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Charts Row
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Job Status Distribution',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Consumer<MetricsProvider>(
                            builder: (context, metricsProvider, child) {
                              final stats = metricsProvider.systemMetrics;
                              return SizedBox(
                                height: 200,
                                child: PieChart(
                                  PieChartData(
                                    sections: [
                                      PieChartSectionData(
                                        value: (stats['completedJobs'] ?? 0).toDouble(),
                                        title: 'Completed',
                                        color: Colors.green,
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        value: (stats['activeJobs'] ?? 0).toDouble(),
                                        title: 'Active',
                                        color: Colors.orange,
                                        radius: 50,
                                      ),
                                      PieChartSectionData(
                                        value: (stats['failedJobs'] ?? 0).toDouble(),
                                        title: 'Failed',
                                        color: Colors.red,
                                        radius: 50,
                                      ),
                                    ],
                                    sectionsSpace: 2,
                                    centerSpaceRadius: 40,
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Recent Activity',
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Consumer<JobExecutionProvider>(
                            builder: (context, jobProvider, child) {
                              if (jobProvider.isLoading) {
                                return const Center(child: CircularProgressIndicator());
                              }
                              
                              final runningJobs = jobProvider.runningJobs;
                              if (runningJobs.isEmpty) {
                                return const Center(
                                  child: Text('No active jobs'),
                                );
                              }
                              
                              return ListView.builder(
                                shrinkWrap: true,
                                itemCount: runningJobs.length,
                                itemBuilder: (context, index) {
                                  final job = runningJobs[index];
                                  return ListTile(
                                    leading: CircleAvatar(
                                      backgroundColor: job.isRunning ? Colors.orange : Colors.green,
                                      child: Icon(
                                        job.isRunning ? Icons.play_arrow : Icons.check,
                                        color: Colors.white,
                                      ),
                                    ),
                                    title: Text(job.tableName),
                                    subtitle: Text('${job.jobType} - ${job.status}'),
                                    trailing: Text(
                                      '${job.recordsProcessed} records',
                                      style: const TextStyle(fontSize: 12),
                                    ),
                                  );
                                },
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Table Configuration Overview
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Table Configurations',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    Consumer<TableConfigProvider>(
                      builder: (context, tableProvider, child) {
                        if (tableProvider.isLoading) {
                          return const Center(child: CircularProgressIndicator());
                        }
                        
                        final configs = tableProvider.tableConfigs;
                        if (configs.isEmpty) {
                          return const Center(
                            child: Text('No table configurations found'),
                          );
                        }
                        
                        return DataTable(
                          columns: const [
                            DataColumn(label: Text('Table Name')),
                            DataColumn(label: Text('Archival Days')),
                            DataColumn(label: Text('Purge Days')),
                            DataColumn(label: Text('Status')),
                          ],
                          rows: configs.map((config) {
                            return DataRow(
                              cells: [
                                DataCell(Text(config.tableName)),
                                DataCell(Text('${config.archivalDays}')),
                                DataCell(Text('${config.purgeDays}')),
                                DataCell(
                                  Chip(
                                    label: Text(config.isActive ? 'Active' : 'Inactive'),
                                    backgroundColor: config.isActive ? Colors.green : Colors.red,
                                    labelStyle: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}