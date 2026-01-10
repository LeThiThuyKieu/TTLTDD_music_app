import 'package:flutter/cupertino.dart';

import '../../models/song_model.dart';
import '../api_service.dart';

class SongService {
  final ApiService _api = ApiService();

  Future<List<SongModel>> getAllSongs() async {
    final response = await _api.get('/admin/songs');
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
    await _api.delete('/admin/songs/$songId');
  }
}
