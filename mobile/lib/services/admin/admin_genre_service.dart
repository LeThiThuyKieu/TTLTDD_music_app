import 'package:flutter/cupertino.dart';

import '../../models/genre_model.dart';
import '../api_service.dart';

class GenreService {
  final ApiService _api = ApiService();

  Future<List<GenreModel>> getAllGenres({int limit = 20, int offset = 0}) async {
    final response = await _api.get('/admin/genres', queryParams: {
      'limit': limit.toString(),
      'offset': offset.toString(),
    });
    debugPrint('JSON from API: $response');

    // Kiểm tra dữ liệu nhận được từ API có phải là 1 list
    if (response['data'] is! List) {
      throw Exception('Invalid API format: data is not a list');
    }

    return (response['data'] as List)
        .map((e) => GenreModel.fromJson(e))
        .toList();
  }

}
