import 'package:flutter/cupertino.dart';

import '../../models/user_model.dart';
import '../api_service.dart';

class UserService {
  final ApiService _api = ApiService();

  Future<List<UserModel>> getAllUsers({int limit = 20, int offset = 0}) async {
    final response = await _api.get('/admin/users', queryParams: {
      'limit': limit.toString(),
      'offset': offset.toString(),
    });
    debugPrint('JSON from API: $response');

    // Kiểm tra dữ liệu nhận được từ API có phải là 1 list
    if (response['data'] is! List) {
      throw Exception('Invalid API format: data is not a list');
    }

    return (response['data'] as List)
        .map((e) => UserModel.fromJson(e))
        .toList();
  }

  // Khoá tài khoản (PATCH /admin/users/:id/status)
  Future<void> updateUserStatus(int userId, int isActive) async {
    final response = await _api.patch(
      '/admin/users/$userId/status',
      body: {'is_active': isActive,},
    );

    if (response['success'] != true) {
      throw Exception(response['message'] ?? 'Cập nhật thất bại');
    }
  }
}
