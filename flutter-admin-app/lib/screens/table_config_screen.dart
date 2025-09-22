import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/table_config.dart';
import '../providers/table_config_provider.dart';
import '../widgets/table_config_form.dart';

class TableConfigScreen extends StatefulWidget {
  const TableConfigScreen({super.key});

  @override
  State<TableConfigScreen> createState() => _TableConfigScreenState();
}

class _TableConfigScreenState extends State<TableConfigScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TableConfigProvider>().loadTableConfigs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Table Configuration'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<TableConfigProvider>().loadTableConfigs();
            },
          ),
        ],
      ),
      body: Consumer<TableConfigProvider>(
        builder: (context, tableProvider, child) {
          if (tableProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (tableProvider.error != null) {
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
                    'Error: ${tableProvider.error}',
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      tableProvider.clearError();
                      tableProvider.loadTableConfigs();
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          return Column(
            children: [
              // Add New Configuration Button
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Table Configurations',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    ElevatedButton.icon(
                      onPressed: () => _showAddConfigDialog(context),
                      icon: const Icon(Icons.add),
                      label: const Text('Add Configuration'),
                    ),
                  ],
                ),
              ),

              // Table Configurations List
              Expanded(
                child: tableProvider.tableConfigs.isEmpty
                    ? const Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.table_chart_outlined,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'No table configurations found',
                              style: TextStyle(fontSize: 16, color: Colors.grey),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Add a new configuration to get started',
                              style: TextStyle(fontSize: 14, color: Colors.grey),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: tableProvider.tableConfigs.length,
                        itemBuilder: (context, index) {
                          final config = tableProvider.tableConfigs[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: config.isActive ? Colors.green : Colors.red,
                                child: Icon(
                                  Icons.table_chart,
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                config.tableName,
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text('Archival: ${config.archivalDays} days'),
                                  Text('Purge: ${config.purgeDays} days'),
                                  Text(
                                    config.isActive ? 'Active' : 'Inactive',
                                    style: TextStyle(
                                      color: config.isActive ? Colors.green : Colors.red,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  switch (value) {
                                    case 'edit':
                                      _showEditConfigDialog(context, config);
                                      break;
                                    case 'delete':
                                      _showDeleteConfirmation(context, config);
                                      break;
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'edit',
                                    child: Row(
                                      children: [
                                        Icon(Icons.edit),
                                        SizedBox(width: 8),
                                        Text('Edit'),
                                      ],
                                    ),
                                  ),
                                  const PopupMenuItem(
                                    value: 'delete',
                                    child: Row(
                                      children: [
                                        Icon(Icons.delete, color: Colors.red),
                                        SizedBox(width: 8),
                                        Text('Delete', style: TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showAddConfigDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => TableConfigForm(
        onSave: (config) async {
          try {
            await context.read<TableConfigProvider>().createTableConfig(config);
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuration created successfully')),
              );
              Navigator.of(context).pop();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showEditConfigDialog(BuildContext context, TableConfig config) {
    showDialog(
      context: context,
      builder: (context) => TableConfigForm(
        initialConfig: config,
        onSave: (updatedConfig) async {
          try {
            await context.read<TableConfigProvider>().updateTableConfig(
              config.id!,
              updatedConfig,
            );
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Configuration updated successfully')),
              );
              Navigator.of(context).pop();
            }
          } catch (e) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          }
        },
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, TableConfig config) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Configuration'),
        content: Text('Are you sure you want to delete the configuration for ${config.tableName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await context.read<TableConfigProvider>().deleteTableConfig(config.id!);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Configuration deleted successfully')),
                  );
                  Navigator.of(context).pop();
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}