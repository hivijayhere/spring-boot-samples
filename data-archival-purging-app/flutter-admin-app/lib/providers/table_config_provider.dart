import 'package:flutter/foundation.dart';
import '../models/table_config.dart';
import '../services/api_service.dart';

class TableConfigProvider with ChangeNotifier {
  List<TableConfig> _tableConfigs = [];
  bool _isLoading = false;
  String? _error;

  List<TableConfig> get tableConfigs => _tableConfigs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadTableConfigs() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tableConfigs = await ApiService.getTableConfigs();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createTableConfig(TableConfig config) async {
    try {
      final newConfig = await ApiService.createTableConfig(config);
      _tableConfigs.add(newConfig);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> updateTableConfig(int id, TableConfig config) async {
    try {
      final updatedConfig = await ApiService.updateTableConfig(id, config);
      final index = _tableConfigs.indexWhere((c) => c.id == id);
      if (index != -1) {
        _tableConfigs[index] = updatedConfig;
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> deleteTableConfig(int id) async {
    try {
      await ApiService.deleteTableConfig(id);
      _tableConfigs.removeWhere((c) => c.id == id);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}