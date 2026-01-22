import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:music_app/models/song_model.dart';
import '../config/api_config.dart';


class PlaylistApi {
  static Future<List<SongModel>> getPlaylistsBySong({
    required int songId,
    required String token,
    int limit = 12,
  }) async {
    final url = Uri.parse(
      '${ApiConfig.baseUrl}${ApiConfig.songPlaylists}/$songId/playlists/songs?limit=$limit',
    );

    print('URL = $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    print('Status = ${response.statusCode}');
    print('Body = ${response.body}');

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);

      final data = body['data'];
      if (data == null || data is! List) {
        // API trả 200 nhưng không có danh sách
        return [];
      }

      return data
          .map<SongModel>((e) => SongModel.fromJson(e))
          .toList();
    }

    throw Exception('HTTP ${response.statusCode}');
  }
}
