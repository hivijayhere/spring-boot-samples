import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:data_archival_admin/providers/table_config_provider.dart';
import 'package:data_archival_admin/providers/job_execution_provider.dart';
import 'package:data_archival_admin/providers/metrics_provider.dart';
import 'package:data_archival_admin/screens/dashboard_screen.dart';
import 'package:data_archival_admin/screens/table_config_screen.dart';
import 'package:data_archival_admin/screens/job_monitoring_screen.dart';
import 'package:data_archival_admin/screens/metrics_screen.dart';
import 'package:data_archival_admin/theme/app_theme.dart';

void main() {
  runApp(const DataArchivalAdminApp());
}

class DataArchivalAdminApp extends StatelessWidget {
  const DataArchivalAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => TableConfigProvider()),
        ChangeNotifierProvider(create: (_) => JobExecutionProvider()),
        ChangeNotifierProvider(create: (_) => MetricsProvider()),
      ],
      child: MaterialApp(
        title: 'Data Archival Admin',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        home: const MainScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;
  
  final List<Widget> _screens = [
    const DashboardScreen(),
    const TableConfigScreen(),
    const JobMonitoringScreen(),
    const MetricsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: Text('Dashboard'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.table_chart_outlined),
                selectedIcon: Icon(Icons.table_chart),
                label: Text('Table Config'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.monitor_outlined),
                selectedIcon: Icon(Icons.monitor),
                label: Text('Job Monitor'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.analytics_outlined),
                selectedIcon: Icon(Icons.analytics),
                label: Text('Metrics'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(
            child: _screens[_selectedIndex],
          ),
        ],
      ),
    );
  }
}