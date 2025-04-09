import 'dart:convert';
import 'dart:developer';
import 'package:admin_notifier/controllers/storage_manager.dart';
import 'package:http/http.dart' as http;

class ApiService {
  final String baseUrl =
      "https://anganwaadi-service-api.vercel.app/api/v1/admin";

  // ApiService({required this.baseUrl});

  Future<dynamic> get(
    String endpoint, {
    Map<String, String>? headers,
    Map<String, String>? queryParams,
  }) async {
    try {
      Uri url = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);
      final response = await http.get(url, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('GET request error: $e');
    }
  }

  Future<dynamic> post(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool includeTokenInHeader = false,
  }) async {
    try {
      final finalHeaders =
          includeTokenInHeader
              ? await _mergeTokenHeaders(headers)
              : _mergeDefaultHeaders(headers);
      Uri url = Uri.parse('$baseUrl$endpoint');
      final response = await http.post(
        url,
        headers: finalHeaders,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      log('POST request error: ${e.toString()}');
      return somethingwentwrong;
    }
  }

  Future<dynamic> patch(
    String endpoint, {
    Map<String, String>? headers,
    dynamic body,
    bool includeTokenInHeader = false,
  }) async {
    try {
      final finalHeaders =
          includeTokenInHeader
              ? await _mergeTokenHeaders(headers)
              : _mergeDefaultHeaders(headers);
      Uri url = Uri.parse('$baseUrl$endpoint');
      final response = await http.patch(
        url,
        headers: finalHeaders,
        body: jsonEncode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      log('PATCH request error: ${e.toString()}');
      return somethingwentwrong;
    }
  }

  // Default headers
  Map<String, String> _mergeDefaultHeaders(Map<String, String>? headers) {
    return {'Content-Type': 'application/json', ...?headers};
  }

  Future<Map<String, String>> _mergeTokenHeaders(
    Map<String, String>? headers,
  ) async {
    final token = await StorageManager.getData('authToken');
    log('token stored was: $token');
    if (token == null) {
      log("relogin required as token was not found in device");
    }
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
      ...?headers,
    };
  }

  // Handle Response
  dynamic _handleResponse(http.Response response) {
    return json.decode(response.body);
    // if (response.statusCode >= 200 && response.statusCode < 300) {
    // } else {
    //   throw Exception('HTTP ${response.statusCode}: ${response.body}');
    // }
  }
}

dynamic somethingwentwrong = {
  'status': 'success',
  'error': true,
  'message': 'Something Went Wrong',
};
