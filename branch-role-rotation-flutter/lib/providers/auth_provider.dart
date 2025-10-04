import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../services/api_service.dart';
import '../utils/app_constants.dart';

class AuthProvider with ChangeNotifier {
  final SharedPreferences _prefs;
  final ApiService _apiService = ApiService();
  
  bool _isLoading = false;
  bool _isLoggedIn = false;
  UserModel? _user;
  String? _error;

  AuthProvider(this._prefs) {
    _initializeAuth();
  }

  bool get isLoading => _isLoading;
  bool get isLoggedIn => _isLoggedIn;
  UserModel? get user => _user;
  String? get error => _error;

  void _initializeAuth() {
    _isLoggedIn = _prefs.getBool(AppConstants.isLoggedInKey) ?? false;
    if (_isLoggedIn) {
      final userJson = _prefs.getString(AppConstants.userKey);
      if (userJson != null) {
        try {
          _user = UserModel.fromJson(json.decode(userJson));
        } catch (e) {
          _isLoggedIn = false;
          _prefs.setBool(AppConstants.isLoggedInKey, false);
        }
      }
    }
  }

  Future<bool> login(String username, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final result = await _apiService.login(username, password);
      
      if (result['user'] != null) {
        _user = UserModel.fromJson(result['user']);
        _isLoggedIn = true;
        notifyListeners();
        return true;
      } else {
        _setError(result['error'] ?? AppConstants.invalidCredentials);
        return false;
      }
    } catch (e) {
      _setError(e.toString().replaceFirst('Exception: ', ''));
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    
    try {
      await _apiService.logout();
    } catch (e) {
      // Ignore logout errors
    } finally {
      _user = null;
      _isLoggedIn = false;
      _setLoading(false);
      notifyListeners();
    }
  }

  Future<bool> validateToken() async {
    if (!_isLoggedIn) return false;

    try {
      final result = await _apiService.validateToken();
      
      if (result['valid'] == true && result['user'] != null) {
        _user = UserModel.fromJson(result['user']);
        notifyListeners();
        return true;
      } else {
        await logout();
        return false;
      }
    } catch (e) {
      await logout();
      return false;
    }
  }

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
}