import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../models/job_role_rotation_model.dart';
import '../models/bm_view_model.dart';
import '../utils/app_constants.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;
  SharedPreferences? _prefs;

  void initialize(SharedPreferences prefs) {
    _prefs = prefs;
    _token = _prefs?.getString(AppConstants.tokenKey);
  }

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    if (_token != null) 'Authorization': 'Bearer $_token',
  };

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body);
    } else if (response.statusCode == 401) {
      await _clearToken();
      throw Exception(AppConstants.sessionExpired);
    } else {
      throw Exception('HTTP ${response.statusCode}: ${response.body}');
    }
  }

  Future<void> _clearToken() async {
    _token = null;
    await _prefs?.remove(AppConstants.tokenKey);
    await _prefs?.setBool(AppConstants.isLoggedInKey, false);
  }

  Future<void> setToken(String token) async {
    _token = token;
    await _prefs?.setString(AppConstants.tokenKey, token);
    await _prefs?.setBool(AppConstants.isLoggedInKey, true);
  }

  // Authentication APIs
  Future<Map<String, dynamic>> login(String username, String password) async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.authEndpoint}/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'username': username,
          'password': password,
        }),
      );

      final result = await _handleResponse(response);
      
      if (result['token'] != null) {
        await setToken(result['token']);
        await _prefs?.setString(AppConstants.userKey, json.encode(result['user']));
      }
      
      return result;
    } catch (e) {
      throw Exception('Login failed: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> validateToken() async {
    try {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.authEndpoint}/validate'),
        headers: _headers,
      );

      return await _handleResponse(response);
    } catch (e) {
      throw Exception('Token validation failed: ${e.toString()}');
    }
  }

  // Job Role Rotation APIs
  Future<List<JobRoleRotationModel>> getMyJobRoleHistory() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.jobRoleEndpoint}/my-history'),
        headers: _headers,
      );

      final result = await _handleResponse(response);
      final List<dynamic> data = result['data'] ?? [];
      
      return data.map((json) => JobRoleRotationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch job role history: ${e.toString()}');
    }
  }

  Future<List<JobRoleRotationModel>> getMyJobRoleHistoryAsOnDate(String asOnDate) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.jobRoleEndpoint}/my-history/as-on-date?asOnDate=$asOnDate'),
        headers: _headers,
      );

      final result = await _handleResponse(response);
      final List<dynamic> data = result['data'] ?? [];
      
      return data.map((json) => JobRoleRotationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch job role history: ${e.toString()}');
    }
  }

  Future<JobRoleRotationModel?> getMyCurrentRole() async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.jobRoleEndpoint}/my-current-role'),
        headers: _headers,
      );

      final result = await _handleResponse(response);
      final data = result['data'];
      
      return data != null ? JobRoleRotationModel.fromJson(data) : null;
    } catch (e) {
      throw Exception('Failed to fetch current role: ${e.toString()}');
    }
  }

  Future<BMViewModel> getBMView(String asOnDate) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.jobRoleEndpoint}/bm-view?asOnDate=$asOnDate'),
        headers: _headers,
      );

      final result = await _handleResponse(response);
      
      return BMViewModel.fromJson(result['data']);
    } catch (e) {
      throw Exception('Failed to fetch BM view: ${e.toString()}');
    }
  }

  Future<List<JobRoleRotationModel>> getTeamJobRoleHistory(String asOnDate) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.jobRoleEndpoint}/team-history?asOnDate=$asOnDate'),
        headers: _headers,
      );

      final result = await _handleResponse(response);
      final List<dynamic> data = result['data'] ?? [];
      
      return data.map((json) => JobRoleRotationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch team history: ${e.toString()}');
    }
  }

  Future<List<JobRoleRotationModel>> getBranchJobRoleHistory(String asOnDate) async {
    try {
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${AppConstants.jobRoleEndpoint}/branch-history?asOnDate=$asOnDate'),
        headers: _headers,
      );

      final result = await _handleResponse(response);
      final List<dynamic> data = result['data'] ?? [];
      
      return data.map((json) => JobRoleRotationModel.fromJson(json)).toList();
    } catch (e) {
      throw Exception('Failed to fetch branch history: ${e.toString()}');
    }
  }

  Future<void> logout() async {
    await _clearToken();
    await _prefs?.remove(AppConstants.userKey);
  }
}