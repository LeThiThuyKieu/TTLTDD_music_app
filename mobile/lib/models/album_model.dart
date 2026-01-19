import 'package:music_app/models/song_model.dart';

import 'artist_model.dart';

class AlbumModel {
  final int? albumId;
  final String title;
  final int? artistId;
  final String? coverUrl;
  final DateTime? releaseDate;
  final int? isActive;
  final ArtistModel? artist;
  final List<SongModel>? songs;

  AlbumModel({
    this.albumId,
    required this.title,
    this.artistId,
    this.coverUrl,
    this.releaseDate,
    this.isActive,
    this.artist,
    this.songs,
  });

  factory AlbumModel.fromJson(Map<String, dynamic> json) {
    return AlbumModel(
      albumId: json['album_id'] as int?,
      title: json['title'] as String,
      artistId: json['artist_id'] as int?,
      coverUrl: json['cover_url'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'] as String)
          : null,
      isActive: json['is_active'] as int?,
      artist: json['artist'] != null
          ? ArtistModel.fromJson(json['artist'])
          : null,
      songs: json['songs'] != null
          ? (json['songs'] as List)
          .map((e) => SongModel.fromJson(e))
          .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'album_id': albumId,
      'title': title,
      'artist_id': artistId,
      'cover_url': coverUrl,
      'release_date': releaseDate?.toIso8601String(),
      'is_active': isActive,
      'artist': artist?.toJson(),
      'songs': songs?.map((s) => s.toJson()).toList(),
    };
  }
}
