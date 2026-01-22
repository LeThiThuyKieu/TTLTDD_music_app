import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../utils/constants.dart';
import 'auth_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();

  factory ApiService() => _instance;

  ApiService._internal();

  final _authService = AuthService();

  Future<String?> _getAuthToken() async {
    try {
      return await _authService.getToken();
    } catch (e) {
      print('Error getting auth token: $e');
    }
    return null;
  }

  Future<Map<String, String>> _getHeaders({bool includeAuth = true}) async {
    final headers = <String, String>{
      'Content-Type': 'application/json',
    };

    if (includeAuth) {
      final token = await _getAuthToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    return headers;
  }

  Future<Map<String, dynamic>> _handleResponse(http.Response response) async {
    // Success: Parse JSON và trả về
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return json.decode(response.body) as Map<String, dynamic>;
    } else if (response.statusCode == 401) {
      //Unauthorized: Token hết hạn hoặc không hợp lệ
      throw Exception(AppConstants.errorUnauthorized);
    } else if (response.statusCode >= 500) {
      //Server Error: Lỗi từ phía server
      throw Exception(AppConstants.errorServer);
    } else {
      //Client Error (400-499): Lỗi từ phía client
      //Parse error message và trả về
      final errorData = json.decode(response.body) as Map<String, dynamic>;
      throw Exception(errorData['error'] ?? AppConstants.errorUnknown);
    }
  }

  // GET request
  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, String>? queryParams,
    bool includeAuth = true,
  }) async {
    try {
      // 1. Tạo URI từ baseUrl + endpoint
      var uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      // 2. Thêm query parameters nếu có
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      // 3. Gửi GET request với headers
      final response = await http.get(
        uri,
        headers: await _getHeaders(includeAuth: includeAuth),
      );

      // 4. Xử lý response
      return await _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(AppConstants.errorNetwork);
      }
      rethrow;
    }
  }

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _getHeaders(includeAuth: includeAuth),
        body: json.encode(body),
      );

      return await _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(AppConstants.errorNetwork);
      }
      rethrow;
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http.put(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _getHeaders(includeAuth: includeAuth),
        body: json.encode(body),
      );

      return await _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(AppConstants.errorNetwork);
      }
      rethrow;
    }
  }

  // DELETE request
  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool includeAuth = true,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _getHeaders(includeAuth: includeAuth),
      );

      return await _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(AppConstants.errorNetwork);
      }
      rethrow;
    }
  }
  // PATCH request
  Future<Map<String, dynamic>> patch(
      String endpoint, {
        Map<String, dynamic>? body,
        bool includeAuth = true,
      }) async {
    try {
      final response = await http.patch(
        Uri.parse('${ApiConfig.baseUrl}$endpoint'),
        headers: await _getHeaders(includeAuth: includeAuth),
        body: json.encode(body ?? {}),
      );

      return await _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(AppConstants.errorNetwork);
      }
      rethrow;
    }
  }

  // UPLOAD FILE (multipart/form-data)
  Future<Map<String, dynamic>> uploadFile(
    String endpoint, {
    required File file,
    required String fieldName,
    bool includeAuth = true,
  }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);
      final headers = await _getHeaders(includeAuth: includeAuth);
      // Multipart không dùng Content-Type: application/json
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      // Add file
      request.files.add(
        await http.MultipartFile.fromPath(
          fieldName,
          file.path,
        ),
      );

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);
      return await _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(AppConstants.errorNetwork);
      }
      rethrow;
    }
  }

  // ================= MULTIPART POST (UPLOAD FILE + DATA) =================
  Future<Map<String, dynamic>> multipartPost(
      String endpoint, {
        required Map<String, String> fields,
        required Map<String, File> files,
        bool includeAuth = true,
      }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('POST', uri);

      // ===== HEADERS =====
      final headers = await _getHeaders(includeAuth: includeAuth);
      headers.remove('Content-Type'); // multipart KHÔNG dùng json
      request.headers.addAll(headers);

      // ===== TEXT FIELDS =====
      request.fields.addAll(fields);

      // ===== FILE FIELDS =====
      for (final entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,     // key backend: music / cover
            entry.value.path, // đường dẫn tuyết đối trong máy
          ),
        );
      }

      // ===== SEND REQUEST =====
      final streamedResponse = await request.send();
      final response =
      await http.Response.fromStream(streamedResponse);

      return await _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('SocketException') ||
          e.toString().contains('Failed host lookup')) {
        throw Exception(AppConstants.errorNetwork);
      }
      rethrow;
    }
  }

  Future<Map<String, dynamic>> multipartPut(
      String endpoint, {
        required Map<String, String> fields,
        required Map<String, File> files,
        bool includeAuth = true,
      }) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}$endpoint');
      final request = http.MultipartRequest('PUT', uri);

      final headers = await _getHeaders(includeAuth: includeAuth);
      headers.remove('Content-Type');
      request.headers.addAll(headers);

      request.fields.addAll(fields);

      for (final entry in files.entries) {
        request.files.add(
          await http.MultipartFile.fromPath(
            entry.key,
            entry.value.path,
          ),
        );
      }

      final streamedResponse = await request.send(); //Gửi request lên server
      final response =
      await http.Response.fromStream(streamedResponse); //Đọc hết dữ liệu từ stream

      return await _handleResponse(response);
    } catch (e) {
      if (e.toString().contains('SocketException')) {
        throw Exception('Lỗi kết nối mạng');
      }
      rethrow;
    }
  }
}
