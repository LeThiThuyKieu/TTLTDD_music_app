import 'song_model.dart';

class PlaylistModel {
  final int playlistId;
  final int userId;
  final String name;
  final String? coverUrl;
  final int isPublic;
  final DateTime? createdAt;

  /// ⚠️ CHỈ CÓ khi gọi GET /playlists/:id
  final List<SongModel>? songs;

  PlaylistModel({
    required this.playlistId,
    required this.userId,
    required this.name,
    this.coverUrl,
    required this.isPublic,
    this.createdAt,
    this.songs,
  });

  static int _toInt(dynamic v) {
    if (v is int) return v;
    if (v is String) return int.tryParse(v) ?? 0;
    return 0;
  }

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      playlistId: _toInt(json['playlist_id'] ?? json['id']),
      userId: _toInt(json['user_id']),
      name: json['name']?.toString() ?? '',
      coverUrl: json['cover_url']?.toString(),
      isPublic: _toInt(json['is_public']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,

      // ✅ CHỈ parse khi backend có trả
      songs: json['songs'] is List
          ? (json['songs'] as List)
          .whereType<Map<String, dynamic>>()
          .map((e) => SongModel.fromJson(e))
          .toList()
          : null,
    );
  }
}
