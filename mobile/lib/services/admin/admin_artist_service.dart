import 'package:flutter/cupertino.dart';

import '../../models/artist_model.dart';
import '../api_service.dart';

class ArtistService {
  final ApiService _api = ApiService();

  Future<List<ArtistModel>> getAllArtists({int limit = 20, int offset = 0}) async {
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

  Future<void> deleteArtist(int artistId) async {
    await _api.delete('/admin/artists/$artistId');
  }
}
