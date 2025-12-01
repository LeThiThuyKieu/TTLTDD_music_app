import 'artist_model.dart';

class SongModel {
  final int? songId;
  final String title;
  final int? albumId;
  final int? genreId;
  final int? duration; // seconds
  final String fileUrl;
  final String? coverUrl;
  final DateTime? releaseDate;
  final int? isActive;
  final List<ArtistModel>? artists;

  SongModel({
    this.songId,
    required this.title,
    this.albumId,
    this.genreId,
    this.duration,
    required this.fileUrl,
    this.coverUrl,
    this.releaseDate,
    this.isActive,
    this.artists,
  });

  factory SongModel.fromJson(Map<String, dynamic> json) {
    return SongModel(
      songId: json['song_id'] as int?,
      title: json['title'] as String,
      albumId: json['album_id'] as int?,
      genreId: json['genre_id'] as int?,
      duration: json['duration'] as int?,
      fileUrl: json['file_url'] as String,
      coverUrl: json['cover_url'] as String?,
      releaseDate: json['release_date'] != null
          ? DateTime.parse(json['release_date'] as String)
          : null,
      isActive: json['is_active'] as int?,
      artists: json['artists'] != null
          ? (json['artists'] as List)
              .map((artist) => ArtistModel.fromJson(artist))
              .toList()
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'song_id': songId,
      'title': title,
      'album_id': albumId,
      'genre_id': genreId,
      'duration': duration,
      'file_url': fileUrl,
      'cover_url': coverUrl,
      'release_date': releaseDate?.toIso8601String(),
      'is_active': isActive,
      'artists': artists?.map((artist) => artist.toJson()).toList(),
    };
  }

  String get durationFormatted {
    if (duration == null) return '0:00';
    final minutes = duration! ~/ 60;
    final seconds = duration! % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}

