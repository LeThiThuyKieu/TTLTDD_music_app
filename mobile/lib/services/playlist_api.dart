import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/playlist_model.dart';

class PlaylistApi {
  static Future<List<PlaylistModel>> getPlaylistsBySong({
    required int songId,
    required String token,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.songPlaylists}/$songId/playlists',
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
          .map((e) => PlaylistModel.fromJson(e))
          .toList();
    }

    throw Exception('Load playlists failed');
  }
}
