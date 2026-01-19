import 'package:shared_preferences/shared_preferences.dart';
import '../utils/constants.dart';
import 'api_service.dart';
import '../config/api_config.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();

  factory AuthService() => _instance;

  AuthService._internal();

  // Lưu JWT token
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyAuthToken, token);
  }

  // Lấy JWT token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyAuthToken);
  }

  // Xóa token
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove(AppConstants.keyUserId);
    await prefs.remove(AppConstants.keyUserEmail);
    await prefs.remove(AppConstants.keyUserName);
    await prefs.remove(AppConstants.keyUserAvatar);
    await prefs.remove(AppConstants.keyUserRole);
  }

  // Lưu thông tin user
  Future<void> saveUserInfo({
    required int userId,
    required String email,
    required String name,
    String? avatarUrl,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keyUserId, userId);
    await prefs.setString(AppConstants.keyUserEmail, email);
    await prefs.setString(AppConstants.keyUserName, name);

    // Sanitize avatarUrl before saving. Avoid saving literal 'null' or empty strings.
    if (avatarUrl != null) {
      final sanitized = avatarUrl.trim();
      if (sanitized.isNotEmpty && sanitized.toLowerCase() != 'null') {
        await prefs.setString(AppConstants.keyUserAvatar, sanitized);
      } else {
        // Ensure we don't keep an invalid value
        await prefs.remove(AppConstants.keyUserAvatar);
      }
    }
  }

  // Kiểm tra đã đăng nhập chưa
  Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  // Lấy tên user
  Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserName);
  }

  // Lấy email user
  Future<String?> getUserEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserEmail);
  }

  // Lấy avatar user
  Future<String?> getUserAvatar() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserAvatar);
  }

  //lưu update name user
  Future<void> saveUserName(String name) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserName, name);
  }

  // Lấy user ID
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(AppConstants.keyUserId);
  }

  //logout
  Future<void> logout() async {
    await clearToken();
  }

  // Lưu avatar user
  Future<void> saveUserAvatar(String avatarUrl) async {
    final prefs = await SharedPreferences.getInstance();
    final sanitized = avatarUrl.trim();
    if (sanitized.isNotEmpty && sanitized.toLowerCase() != 'null') {
      await prefs.setString(AppConstants.keyUserAvatar, sanitized);
    } else {
      await prefs.remove(AppConstants.keyUserAvatar);
    }
  }

  // Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final api = ApiService();
      final response = await api.post(
        '/auth/login',
        {
          'email': email,
          'password': password,
        },
        includeAuth: false,
      );

      if (response['success'] != true || response['data'] == null) {
        throw Exception(response['error'] ?? 'Đăng nhập thất bại');
      }

      final data = response['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final userData = data['user'] as Map<String, dynamic>;

      await saveToken(token);

      String? avatarUrl = userData['avatar_url'] as String?;
      if (avatarUrl != null &&
          avatarUrl.isNotEmpty &&
          avatarUrl.startsWith('/')) {
        avatarUrl = '${ApiConfig.baseUrl}$avatarUrl';
      }

      await saveUserInfo(
        userId: userData['user_id'] as int,
        email: userData['email'] as String,
        name: userData['name'] as String,
        avatarUrl: avatarUrl,
      );
      final role = userData['role'] as String? ?? 'user';
      await saveUserRole(role);
    } catch (e) {
      rethrow;
    }
  }

  // Register
  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final api = ApiService();
      final response = await api.post(
        '/auth/register',
        {
          'name': name,
          'email': email,
          'password': password,
        },
        includeAuth: false,
      );

      if (response['success'] != true || response['data'] == null) {
        throw Exception(response['error'] ?? 'Đăng ký thất bại');
      }

      final data = response['data'] as Map<String, dynamic>;
      final token = data['token'] as String;
      final userData = data['user'] as Map<String, dynamic>;

      await saveToken(token);

      String? avatarUrl = userData['avatar_url'] as String?;
      if (avatarUrl != null &&
          avatarUrl.isNotEmpty &&
          avatarUrl.startsWith('/')) {
        avatarUrl = '${ApiConfig.baseUrl}$avatarUrl';
      }

      await saveUserInfo(
        userId: userData['user_id'] as int,
        email: userData['email'] as String,
        name: userData['name'] as String,
        avatarUrl: avatarUrl,
      );
      final role = userData['role'] as String? ?? 'user';
      await saveUserRole(role);
    } catch (e) {
      rethrow;
    }
  }

  // Forgot password
  Future<void> forgotPassword({
    required String email,
  }) async {
    try {
      final api = ApiService();
      final response = await api.post(
        '/auth/forgot-password',
        {'email': email},
        includeAuth: false,
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Gửi mã thất bại');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Verify OTP
  Future<void> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      final api = ApiService();
      final response = await api.post(
        '/auth/verify-otp',
        {'email': email, 'otp': otp},
        includeAuth: false,
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Mã xác minh không đúng');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) async {
    try {
      final api = ApiService();
      final response = await api.post(
        '/auth/reset-password',
        {
          'email': email,
          'otp': otp,
          'new_password': newPassword,
        },
        includeAuth: false,
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Đặt lại mật khẩu thất bại');
      }
    } catch (e) {
      rethrow;
    }
  }
  // Lưu role
  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConstants.keyUserRole, role);
  }

// Lấy role
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(AppConstants.keyUserRole);
  }


  //  /// Bất đồng bộ trả về token
  Future<String?> get token async => await getToken();
}
