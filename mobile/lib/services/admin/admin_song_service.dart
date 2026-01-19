import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../models/song_model.dart';
import '../api_service.dart';

class SongService {
  final ApiService _api = ApiService();

  // DS BÀI HÁT
  Future<({List<SongModel> songs, int total,})> getAllSongs({
    int limit = 10,
    int offset = 0,
  }) async {
    final response = await _api.get('/admin/songs',
      queryParams: {
        'limit': limit.toString(),
        'offset': offset.toString(),
      },
    );

    final data = response['data'];
    if (data is! List) {
      throw Exception('Invalid API format');
    }

    return (
    songs: data.map((e) => SongModel.fromJson(e)).toList(),
    total: response['total'] as int,
    );
  }

  // Future<List<SongModel>> getAllSongs({int limit = 10, int offset = 0}) async {
  //   final response = await _api.get('/admin/songs', queryParams: {
  //     'limit': limit.toString(),
  //     'offset': offset.toString(),
  //   });
  //   debugPrint('JSON from API: $response');
  //
  //   // Kiểm tra dữ liệu nhận được từ API có phải là 1 list
  //   if (response['data'] is! List) {
  //     throw Exception('Invalid API format: data is not a list');
  //   }
  //
  //   return (response['data'] as List)
  //       .map((e) => SongModel.fromJson(e))
  //       .toList();
  // }

  // DANH SÁCH BÀI HÁT CHO SELECT
  // Future<List<SongModel>> getSongsForSelect() async {
  //   final response = await _api.get('/admin/songs/select');
  //
  //   final data = response['data'];
  //   if (data is! List) {
  //     throw Exception('Invalid API format');
  //   }
  //
  //   return data.map((e) => SongModel.fromJson(e)).toList();
  // }

  // DS bài hát cho select
  Future<List<Map<String, dynamic>>> getSongsForSelect() async {
    final response = await _api.get('/admin/songs/select');

    final data = response['data'];
    if (data is! List) {
      throw Exception('Invalid API format');
    }

    return List<Map<String, dynamic>>.from(data);
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

  // DETAIL BÀI HÁT
  Future<SongModel> getSongDetail(int songId) async {
    final res = await _api.get('/admin/songs/$songId');
    if (res['data'] == null) {
      throw Exception('Song detail not found');
    }
    return SongModel.fromJson(res['data']);
  }


  // UPDATE BÀI HÁT
  Future<SongModel> updateSong({
    required int songId,
    required String title,
    required int genreId,
    int? albumId,
    required List<int> artistIds,
    required int duration,
    String? lyrics,
    required bool isActive,
    File? musicFile,
    File? coverImage,
  }) async {
    debugPrint('Updating song ID: $songId');

    final response = await _api.multipartPut('/admin/songs/$songId',
      fields: {
        'title': title,
        'genre_id': genreId.toString(),
        'duration': duration.toString(),
        'artist_ids': artistIds.join(','),
        'is_active': isActive ? '1' : '0',
        if (albumId != null) 'album_id': albumId.toString(),
        if (lyrics != null) 'lyrics': lyrics,
      },
      files: {
        if (musicFile != null) 'music': musicFile,
        if (coverImage != null) 'cover': coverImage,
      },
    );

    if (response['data'] == null) {
      throw Exception('Update song failed');
    }

    return SongModel.fromJson(response['data']);
  }
}