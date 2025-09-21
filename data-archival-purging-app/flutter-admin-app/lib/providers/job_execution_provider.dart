import 'package:flutter/foundation.dart';
import '../models/job_execution.dart';
import '../services/api_service.dart';

class JobExecutionProvider with ChangeNotifier {
  List<JobExecution> _runningJobs = [];
  List<JobExecution> _jobHistory = [];
  Map<String, dynamic> _jobStats = {};
  bool _isLoading = false;
  String? _error;

  List<JobExecution> get runningJobs => _runningJobs;
  List<JobExecution> get jobHistory => _jobHistory;
  Map<String, dynamic> get jobStats => _jobStats;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadRunningJobs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _runningJobs = await ApiService.getJobStatus();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadJobHistory({String? tableName, int page = 0, int size = 10}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _jobHistory = await ApiService.getJobHistory(
        tableName: tableName,
        page: page,
        size: size,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadJobStats() async {
    try {
      _jobStats = await ApiService.getJobStats();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> triggerArchivalJob(String tableName) async {
    try {
      await ApiService.triggerArchivalJob(tableName);
      // Refresh running jobs after triggering
      await loadRunningJobs();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> triggerPurgeJob(String tableName) async {
    try {
      await ApiService.triggerPurgeJob(tableName);
      // Refresh running jobs after triggering
      await loadRunningJobs();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}