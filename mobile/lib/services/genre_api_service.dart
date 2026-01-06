import '../models/genre_model.dart';
import '../models/song_model.dart';
import '../config/api_config.dart';
import 'api_service.dart';

class GenreApiService {
  GenreApiService._();
  static final GenreApiService instance = GenreApiService._();

  final ApiService _api = ApiService();

  Future<List<GenreModel>> getAllGenres() async {
    final res = await _api.get(ApiConfig.genres, includeAuth: false);
    final data = (res['data'] is List) ? (res['data'] as List) : [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => GenreModel.fromJson(e))
        .toList();
  }

  Future<List<GenreModel>> getGenres() => getAllGenres();

  Future<GenreModel> getGenre(int genreId) async {
    final res = await _api.get('${ApiConfig.genres}/$genreId', includeAuth: false);
    final data = (res['data'] is Map<String, dynamic>)
        ? res['data'] as Map<String, dynamic>
        : <String, dynamic>{};
    return GenreModel.fromJson(data);
  }

  // ✅ FIX: lấy bài theo genre đúng route BE: /songs/genre/:genreId
  Future<List<SongModel>> getSongsByGenre(
      int genreId, {
        int limit = 50,
        int offset = 0,
      }) async {
    final endpoint = '${ApiConfig.songsByGenre}/$genreId';
    final res = await _api.get(
      endpoint,
      includeAuth: false,
      queryParams: {
        'limit': '$limit',
        'offset': '$offset',
      },
    );

    final data = (res['data'] is List) ? (res['data'] as List) : [];
    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => SongModel.fromJson(e))
        .toList();
  }
}
