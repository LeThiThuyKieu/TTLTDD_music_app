import 'dart:io';

import 'api_service.dart';
import 'auth_service.dart';

class ProfileService {
  final ApiService _apiService = ApiService();
  final AuthService _authService = AuthService();

  // Update profile (name)
  Future<void> updateProfile({
    required String name,
  }) async {
    try {
      final response = await _apiService.put(
        '/users/name-profile',
        {
          'name': name,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Cập nhật thất bại');
      }

      final updatedName = response['data']['name'];

      // cập nhật lại local storage
      await _authService.saveUserName(updatedName);
    } catch (e) {
      rethrow;
    }
  }

  // Change password
  Future<void> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      final response = await _apiService.post(
        '/users/change-password',
        {
          'old_password': oldPassword,
          'new_password': newPassword,
        },
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Đổi mật khẩu thất bại');
      }
    } catch (e) {
      rethrow;
    }
  }

  // Upload avatar
  Future<String> uploadAvatar(File image) async {
    try {
      final response = await _apiService.uploadFile(
        '/users/upload-avatar',
        file: image,
        fieldName: 'avatar',
      );

      if (response['success'] != true) {
        throw Exception(response['error'] ?? 'Upload avatar thất bại');
      }

      final avatarUrl = response['data']['avatar_url'];

      // lưu local
      await _authService.saveUserAvatar(avatarUrl);

      return avatarUrl;
    } catch (e) {
      rethrow;
    }
  }
}
