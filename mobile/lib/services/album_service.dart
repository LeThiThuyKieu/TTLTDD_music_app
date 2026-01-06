import '../models/album_model.dart';
import '../models/song_model.dart';
import 'api_service.dart';

class AlbumService {
  final ApiService _apiService = ApiService();

  Future<AlbumModel> getAlbumById(int albumId) async {
    final response = await _apiService.get(
      '/albums/$albumId',
      includeAuth: true,
    );

    final data = response['data'];
    return AlbumModel.fromJson(data);
  }

  Future<List<SongModel>> getSongsByAlbum(int albumId) async {
    final response = await _apiService.get(
      '/albums/$albumId/songs',
      includeAuth: true,
    );

    final List list = response['data'];
    return list.map((e) => SongModel.fromJson(e)).toList();
  }

  Future<List<AlbumModel>> getAlbums({int limit = 50, int page = 1}) async {
    final response = await _apiService.get(
      '/albums',
      queryParams: {
        'limit': limit.toString(),
        'page': page.toString(),
      },
      includeAuth: true,
    );

    final List list = response['data'];
    return list.map((e) => AlbumModel.fromJson(e)).toList();
  }
}
