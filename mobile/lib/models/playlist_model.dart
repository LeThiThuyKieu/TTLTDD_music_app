import 'song_model.dart';

class PlaylistModel {
  final int? playlistId;
  final int userId;
  final String name;
  final String? coverUrl;
  final int? isPublic;
  final DateTime? createdAt;
  final List<SongModel>? songs;

  PlaylistModel({
    this.playlistId,
    required this.userId,
    required this.name,
    this.coverUrl,
    this.isPublic,
    this.createdAt,
    this.songs,
  });

  factory PlaylistModel.fromJson(Map<String, dynamic> json) {
    return PlaylistModel(
      playlistId: json['playlist_id'] as int?,
      userId: json['user_id'] as int,
      name: json['name'] as String,
      coverUrl: json['cover_url'] as String?,
      isPublic: json['is_public'] as int?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      songs: json['songs'] != null
          ? (json['songs'] as List)
              .map((song) => SongModel.fromJson(song))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'playlist_id': playlistId,
      'user_id': userId,
      'name': name,
      'cover_url': coverUrl,
      'is_public': isPublic,
      'created_at': createdAt?.toIso8601String(),
      'songs': songs?.map((song) => song.toJson()).toList(),
    };
  }

  bool get isPublicPlaylist => isPublic == 1;
}

