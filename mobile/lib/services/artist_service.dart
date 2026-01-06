import '../models/artist_model.dart';
import '../models/song_model.dart';
import 'api_service.dart';

class ArtistService {
  final ApiService _apiService = ApiService();

  // Lấy danh sách nghệ sĩ (viết been home_api_service.dart rồi)

  // Lấy danh sách bài hát theo artist
  Future<List<SongModel>> getSongsByArtist(
      int artistId, {
        int limit = 20,
        int page = 1,
      }) async {
    final response = await _apiService.get(
      '/artists/$artistId/songs',
      queryParams: {
        'limit': limit.toString(),
        'page': page.toString(),
      },
      includeAuth: true,
    );

    final List list = response['data'];
    return list.map((e) => SongModel.fromJson(e)).toList();
  }
}
