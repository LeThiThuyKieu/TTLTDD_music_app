import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:music_app/models/song_model.dart';
import '../config/api_config.dart';
import '../models/playlist_model.dart';

class PlaylistApi {
  static Future<List<SongModel>> getPlaylistsBySong({
    required int songId,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.songPlaylists}/$songId/playlists/songs',
    );

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      return (body['data'] as List)
          .map((e) => SongModel.fromJson(e))
          .toList();
    }

    throw Exception('Load suggested songs failed');
  }

}
