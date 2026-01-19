import 'dart:io';

import 'package:flutter/cupertino.dart';

import '../../models/artist_model.dart';
import '../api_service.dart';

class ArtistService {
  final ApiService _api = ApiService();
// DANH SÁCH NGHỆ SĨ
  Future<List<ArtistModel>> getAllArtists({int limit = 100, int offset = 0}) async {
    final response = await _api.get('/admin/artists', queryParams: {
      'limit': limit.toString(),
      'offset': offset.toString(),
    });
    debugPrint('JSON from API: $response');

    // Kiểm tra dữ liệu nhận được từ API có phải là 1 list
    if (response['data'] is! List) {
      throw Exception('Invalid API format: data is not a list');
    }

    return (response['data'] as List)
        .map((e) => ArtistModel.fromJson(e))
        .toList();
  }

  // XOÁ NGHỆ SĨ
  Future<void> deleteArtist(int artistId) async {
    await _api.delete('/admin/artists/$artistId');
  }

  //THÊM NGHỆ SĨ
  Future<ArtistModel> createArtist({
    required String name,
    required File avatarFile,
    required String description,
  }) async {
    debugPrint('Creating artist: $name');

    final response = await _api.multipartPost('/admin/artists',
      fields: {
        'name': name,
        if (description != null && description.isNotEmpty) 'description': description,
      },
      files: {
        'avatar': avatarFile,
      },
    );

    if (response['data'] == null) {
      throw Exception('Create artist failed');
    }

    return ArtistModel.fromJson(response['data']);
  }

  // CẬP NHẬP THÔNG TIN
  Future<ArtistModel> updateArtist({
    required int artistId,
    required String name,
    String? description,
    bool? isActive,
    File? avatarFile,
  }) async {
    final response = await _api.multipartPut(
      '/admin/artists/$artistId',
      fields: {'name': name,
        if (description != null) 'description': description,
        if (isActive != null) 'is_active': isActive ? '1' : '0',
      },
      files: {
        if (avatarFile != null) 'avatar': avatarFile,
      },
    );

    if (response['data'] == null) {
      throw Exception('Update artist failed');
    }

    return ArtistModel.fromJson(response['data']);
  }

  // THÔNG TIN CHI TIẾT ARTIST THEO ID
  Future<ArtistModel> getArtistDetail(int artistId) async {
    final res = await _api.get('/admin/artists/$artistId');
    if (res['data'] == null) {
      throw Exception('Artist not found');
    }
    return ArtistModel.fromJson(res['data']);
  }
}
