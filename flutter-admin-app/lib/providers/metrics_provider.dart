import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class MetricsProvider with ChangeNotifier {
  Map<String, dynamic> _systemMetrics = {};
  Map<String, dynamic> _tableMetrics = {};
  bool _isLoading = false;
  String? _error;

  Map<String, dynamic> get systemMetrics => _systemMetrics;
  Map<String, dynamic> get tableMetrics => _tableMetrics;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadSystemMetrics() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // For now, we'll use job stats as system metrics
      // In a real implementation, you'd have a dedicated system metrics endpoint
      _systemMetrics = await ApiService.getJobStats();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadTableMetrics(String tableName) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // This would call a dedicated table metrics endpoint
      // For now, we'll use a placeholder
      _tableMetrics = {
        'tableName': tableName,
        'totalRecords': 0,
        'archivedRecords': 0,
        'purgedRecords': 0,
        'lastArchivalDate': null,
        'lastPurgeDate': null,
      };
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}