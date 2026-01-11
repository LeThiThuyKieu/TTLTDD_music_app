import 'package:flutter/cupertino.dart';

import '../../models/album_model.dart';
import '../api_service.dart';

class AlbumService {
  final ApiService _api = ApiService();

  Future<List<AlbumModel>> getAllAlbums({int limit = 20, int offset = 0}) async {
    final response = await _api.get('/admin/albums', queryParams: {
      'limit': limit.toString(),
      'offset': offset.toString(),
    });
    debugPrint('JSON from API: $response');

    // Kiểm tra dữ liệu nhận được từ API có phải là 1 list
    if (response['data'] is! List) {
      throw Exception('Invalid API format: data is not a list');
    }

    return (response['data'] as List)
        .map((e) => AlbumModel.fromJson(e))
        .toList();
  }

  Future<void> deleteAlbum(int albumId) async {
    final response = await _api.delete('/admin/albums/$albumId');
    if (response['success'] != true) {
      throw Exception('Xóa thất bại từ server');
    }
  }
}
