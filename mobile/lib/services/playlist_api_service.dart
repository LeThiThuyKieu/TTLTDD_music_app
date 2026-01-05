import '../models/playlist_model.dart';
import 'api_service.dart';

class PlaylistApiService {
  PlaylistApiService._();
  static final PlaylistApiService instance = PlaylistApiService._();

  final ApiService _api = ApiService();

  Future<List<PlaylistModel>> getMyPlaylists() async {
    final res = await _api.get('/playlists/my');
    final data = (res['data'] ?? res) as dynamic;

    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map((e) => PlaylistModel.fromJson(e))
          .toList();
    }
    return [];
  }

  Future<PlaylistModel> getPlaylistDetail(int playlistId) async {
    final res = await _api.get('/playlists/$playlistId');

    // BE trả { success, data }
    final data = res['data'] as Map<String, dynamic>;

    return PlaylistModel.fromJson(data);
  }


  Future<void> createPlaylist({
    required String name,
    int? isPublic,
    String? coverUrl,
  }) async {
    await _api.post('/playlists', {
      'name': name,
      if (isPublic != null) 'is_public': isPublic,
      if (coverUrl != null) 'cover_url': coverUrl,
    });
  }

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
