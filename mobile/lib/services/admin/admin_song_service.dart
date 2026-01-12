import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../models/song_model.dart';
import '../api_service.dart';

class SongService {
  final ApiService _api = ApiService();

  // DS BÀI HÁT
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

  // XOÁ BÀI HÁT
  Future<void> deleteSong(int songId) async {
    final response = await _api.delete('/admin/songs/$songId');
    if (response['success'] != true) {
      throw Exception('Xóa thất bại từ server');
    }
  }

  //THÊM BÀI HÁT
  Future<SongModel> createSong({
    required String title,
    required int genreId,
    required List<int> artistIds,
    required int duration,
    String? lyrics,
    File? musicFile,
    File? coverImage,
  }) async {
    debugPrint('Uploading song: $title');

    final response = await _api.multipartPost('/admin/songs',
      fields: {
        'title': title,
        'genre_id': genreId.toString(),
        'duration': duration.toString(),
        if (lyrics != null) 'lyrics': lyrics,

        // Gửi nhiều artist_id (backend thường nhận array)
        'artist_ids': artistIds.join(','),
      },
      files: {
        if (musicFile != null) 'music': musicFile,
        if (coverImage != null) 'cover': coverImage,
      },
    );

    if (response['data'] == null) {
      throw Exception('Invalid response from server');
    }

    return SongModel.fromJson(response['data']);
  }
}
