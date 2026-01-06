import '../models/genre_model.dart';
import 'api_service.dart';

class GenreApiService {
  GenreApiService._();
  static final GenreApiService instance = GenreApiService._();

  final ApiService _api = ApiService();

  // GET /genres -> { success: true, data: [...] }
  Future<List<GenreModel>> getAllGenres() async {
    final res = await _api.get('/genres', includeAuth: false);

    final data = (res['data'] is List) ? (res['data'] as List) : [];

    return data
        .whereType<Map<String, dynamic>>()
        .map((e) => GenreModel.fromJson(e))
        .toList();
  }

  // ✅ Alias để bạn gọi getGenres() cho tiện
  Future<List<GenreModel>> getGenres() => getAllGenres();
}
