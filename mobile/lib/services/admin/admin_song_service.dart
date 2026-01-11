import 'package:flutter/cupertino.dart';

import '../../models/song_model.dart';
import '../api_service.dart';

class SongService {
  final ApiService _api = ApiService();

  Future<List<SongModel>> getAllSongs({int limit = 20, int offset = 0}) async {
    final response = await _api.get('/admin/songs', queryParams: {
      'limit': limit.toString(),
      'offset': offset.toString(),
    });
    debugPrint('JSON from API: $response');

    // Kiểm tra dữ liệu nhận được từ API có phải là 1 list
    if (response['data'] is! List) {
      throw Exception('Invalid API format: data is not a list');
    }

    return (response['data'] as List)
        .map((e) => SongModel.fromJson(e))
        .toList();
  }

  Future<void> deleteSong(int songId) async {
    final response = await _api.delete('/admin/songs/$songId');
    if (response['success'] != true) {
      throw Exception('Xóa thất bại từ server');
    }
  }
}
