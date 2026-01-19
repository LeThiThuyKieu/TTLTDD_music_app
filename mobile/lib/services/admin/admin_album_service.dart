import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../models/album_model.dart';
import '../api_service.dart';

class AlbumService {
  final ApiService _api = ApiService();
// LẤY DANH SÁCH ALBUM
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

  // XOÁ ALBUM
  Future<void> deleteAlbum(int albumId) async {
    final response = await _api.delete('/admin/albums/$albumId');
    if (response['success'] != true) {
      throw Exception('Xóa thất bại từ server');
    }
  }

  // LẤY CHI TIẾT ALBUM
  Future<AlbumModel> getAlbumDetail(int albumId) async {
    final response = await _api.get('/admin/albums/$albumId');
    debugPrint('Album detail JSON: $response');

    if (response['data'] == null) {
      throw Exception('Album not found');
    }

    return AlbumModel.fromJson(response['data']);
  }

// THÊM ALBUM
  Future<AlbumModel> createAlbum({
    required String title,
    required int artistId,
    required List<int> songIds,
    File? coverFile,
    int? isActive,
  }) async {
    final response = await _api.multipartPost('/admin/albums',
      fields: {
        'title': title,
        'artist_id': artistId.toString(),
        'song_ids': songIds.join(','), // gửi dưới dạng CSV
        if (isActive != null) 'is_active': isActive.toString(),
      },
      files: {
        if (coverFile != null) 'cover': coverFile,
      },
    );

    if (response['data'] == null) {
      throw Exception('Tạo album thất bại');
    }

    return AlbumModel.fromJson(response['data']);
  }

  // CẬP NHÂPK ALBUM
  Future<AlbumModel> updateAlbum({
    required int albumId,
    required String title,
    required int artistId,
    required List<int> songIds,
    File? coverFile,
    int? isActive,
  }) async {
    final response = await _api.multipartPut('/admin/albums/$albumId',
      fields: {
        'title': title,
        'artist_id': artistId.toString(),
        'song_ids': songIds.join(','),
        if (isActive != null) 'is_active': isActive.toString(),
      },
      files: {
        if (coverFile != null) 'cover': coverFile,
      },
    );

    if (response['data'] == null) {
      throw Exception('Cập nhật album thất bại');
    }

    return AlbumModel.fromJson(response['data']);
  }
}
