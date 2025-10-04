import 'package:flutter/material.dart';
import '../models/job_role_rotation_model.dart';
import '../models/bm_view_model.dart';
import '../services/api_service.dart';

class JobRoleProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  String? _error;
  List<JobRoleRotationModel> _myJobRoleHistory = [];
  List<JobRoleRotationModel> _teamJobRoleHistory = [];
  List<JobRoleRotationModel> _branchJobRoleHistory = [];
  JobRoleRotationModel? _currentRole;
  BMViewModel? _bmView;
  String _selectedAsOnDate = '';

  bool get isLoading => _isLoading;
  String? get error => _error;
  List<JobRoleRotationModel> get myJobRoleHistory => _myJobRoleHistory;
  List<JobRoleRotationModel> get teamJobRoleHistory => _teamJobRoleHistory;
  List<JobRoleRotationModel> get branchJobRoleHistory => _branchJobRoleHistory;
  JobRoleRotationModel? get currentRole => _currentRole;
  BMViewModel? get bmView => _bmView;
  String get selectedAsOnDate => _selectedAsOnDate;

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _clearError();
    notifyListeners();
  }

  void setAsOnDate(String date) {
    _selectedAsOnDate = date;
    notifyListeners();
  }

  Future<void> loadMyJobRoleHistory() async {
    _setLoading(true);
    _clearError();

    try {
      _myJobRoleHistory = await _apiService.getMyJobRoleHistory();
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyJobRoleHistoryAsOnDate(String asOnDate) async {
    _setLoading(true);
    _clearError();

    try {
      _myJobRoleHistory = await _apiService.getMyJobRoleHistoryAsOnDate(asOnDate);
      _selectedAsOnDate = asOnDate;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadMyCurrentRole() async {
    _setLoading(true);
    _clearError();

    try {
      _currentRole = await _apiService.getMyCurrentRole();
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadBMView(String asOnDate) async {
    _setLoading(true);
    _clearError();

    try {
      _bmView = await _apiService.getBMView(asOnDate);
      _selectedAsOnDate = asOnDate;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadTeamJobRoleHistory(String asOnDate) async {
    _setLoading(true);
    _clearError();

    try {
      _teamJobRoleHistory = await _apiService.getTeamJobRoleHistory(asOnDate);
      _selectedAsOnDate = asOnDate;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadBranchJobRoleHistory(String asOnDate) async {
    _setLoading(true);
    _clearError();

    try {
      _branchJobRoleHistory = await _apiService.getBranchJobRoleHistory(asOnDate);
      _selectedAsOnDate = asOnDate;
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      _setLoading(false);
    }
  }

  void clearData() {
    _myJobRoleHistory.clear();
    _teamJobRoleHistory.clear();
    _branchJobRoleHistory.clear();
    _currentRole = null;
    _bmView = null;
    _selectedAsOnDate = '';
    _clearError();
    notifyListeners();
  }
}