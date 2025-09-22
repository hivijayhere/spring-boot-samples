import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/table_config.dart';
import '../models/job_execution.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';
  
  // Table Configuration APIs
  static Future<List<TableConfig>> getTableConfigs() async {
    final response = await http.get(Uri.parse('$baseUrl/v1/config/tables'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => TableConfig.fromJson(json)).toList();
    }
    throw Exception('Failed to load table configs');
  }

  static Future<TableConfig> createTableConfig(TableConfig config) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/config/tables'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(config.toJson()),
    );
    if (response.statusCode == 201) {
      return TableConfig.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to create table config');
  }

  static Future<TableConfig> updateTableConfig(int id, TableConfig config) async {
    final response = await http.put(
      Uri.parse('$baseUrl/v1/config/tables/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(config.toJson()),
    );
    if (response.statusCode == 200) {
      return TableConfig.fromJson(json.decode(response.body));
    }
    throw Exception('Failed to update table config');
  }

  static Future<void> deleteTableConfig(int id) async {
    final response = await http.delete(Uri.parse('$baseUrl/v1/config/tables/$id'));
    if (response.statusCode != 204) {
      throw Exception('Failed to delete table config');
    }
  }

  // Job Execution APIs
  static Future<List<JobExecution>> getJobStatus() async {
    final response = await http.get(Uri.parse('$baseUrl/v1/jobs/status'));
    if (response.statusCode == 200) {
      List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => JobExecution.fromJson(json)).toList();
    }
    throw Exception('Failed to load job status');
  }

  static Future<List<JobExecution>> getJobHistory({String? tableName, int page = 0, int size = 10}) async {
    String url = '$baseUrl/v1/jobs/history?page=$page&size=$size';
    if (tableName != null && tableName.isNotEmpty) {
      url += '&tableName=$tableName';
    }
    
    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      Map<String, dynamic> jsonResponse = json.decode(response.body);
      List<dynamic> jsonList = jsonResponse['content'] ?? jsonResponse;
      return jsonList.map((json) => JobExecution.fromJson(json)).toList();
    }
    throw Exception('Failed to load job history');
  }

  static Future<Map<String, dynamic>> getJobStats() async {
    final response = await http.get(Uri.parse('$baseUrl/v1/jobs/stats'));
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to load job stats');
  }

  // Data Archival APIs
  static Future<void> triggerArchivalJob(String tableName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/data/trigger/archive?tableName=$tableName'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to trigger archival job');
    }
  }

  static Future<void> triggerPurgeJob(String tableName) async {
    final response = await http.post(
      Uri.parse('$baseUrl/v1/data/trigger/purge?tableName=$tableName'),
    );
    if (response.statusCode != 200) {
      throw Exception('Failed to trigger purge job');
    }
  }

  static Future<Map<String, dynamic>> previewArchivalData(String tableName, int days) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/data/preview/archive?tableName=$tableName&days=$days'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to preview archival data');
  }

  static Future<Map<String, dynamic>> previewPurgeData(String tableName, int days) async {
    final response = await http.get(
      Uri.parse('$baseUrl/v1/data/preview/purge?tableName=$tableName&days=$days'),
    );
    if (response.statusCode == 200) {
      return json.decode(response.body);
    }
    throw Exception('Failed to preview purge data');
  }
}