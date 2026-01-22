import 'package:music_app/models/song_model.dart';
import 'api_service.dart';

class SongService {
  static final SongService _instance = SongService._internal();

  final ApiService _apiService = ApiService ();

  SongService._internal();

  factory SongService() {
    return _instance;
  }

  static SongService get instance => _instance;

  /// Lấy chi tiết bài hát (đầy đủ: song + artists + album + genre)
  Future<SongModel> getSongDetail(int songId) async {
    final response = await _apiService.get(
      '/songs/$songId/detail',
      includeAuth: true,
    );
    if (response['data'] == null) {
      throw Exception('Song detail not found');
    }
    return SongModel.fromJson(response['data']);
  }
}
