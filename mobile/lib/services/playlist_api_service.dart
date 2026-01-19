import '../models/playlist_model.dart';
import 'api_service.dart';

class PlaylistApiService {
  PlaylistApiService._();
  static final PlaylistApiService instance = PlaylistApiService._();

  final ApiService _api = ApiService();

  Future<List<PlaylistModel>> getMyPlaylists() async {
    final res = await _api.get('/playlists/my');

    // BE: { success: true, data: [...] }
    final raw = (res is Map && res['data'] != null) ? res['data'] : res;

    if (raw is List) {
      // ✅ Fix quan trọng: ép từng item về Map<String, dynamic>
      // tránh whereType lọc mất vì kiểu Map<dynamic,dynamic>
      return raw.map((e) {
        final map = Map<String, dynamic>.from(e as Map);
        return PlaylistModel.fromJson(map);
      }).toList();
    }

    return [];
  }

  Future<PlaylistModel> getPlaylistDetail(int playlistId) async {
    final res = await _api.get('/playlists/$playlistId');

    // BE: { success: true, data: {...} }
    final data = (res is Map && res['data'] is Map)
        ? Map<String, dynamic>.from(res['data'] as Map)
        : Map<String, dynamic>.from(res as Map);

    return PlaylistModel.fromJson(data);
  }

  Future<void> createPlaylist({
    required String name,
    bool? isPublic,
    String? coverUrl,
  }) async {
    await _api.post('/playlists', {
      'name': name,
      if (isPublic != null) 'is_public': isPublic,
      if (coverUrl != null) 'cover_url': coverUrl,
    });
  }

  /// ⚠️ backend của bạn hiện CHƯA có PUT /playlists/:id -> rename sẽ fail.
  Future<void> updatePlaylist(int playlistId, {required String name}) async {
    await _api.put('/playlists/$playlistId', {'name': name});
  }

  Future<void> deletePlaylist(int playlistId) async {
    await _api.delete('/playlists/$playlistId');
  }

  Future<void> addSongToPlaylist(int playlistId, int songId) async {
    await _api.post('/playlists/$playlistId/songs', {'song_id': songId});
  }

  Future<void> removeSongFromPlaylist(int playlistId, int songId) async {
    await _api.delete('/playlists/$playlistId/songs/$songId');
  }
}
