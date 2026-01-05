import 'package:music_app/models/genre_model.dart';

import '../config/api_config.dart';
import '../models/song_model.dart';
import '../models/artist_model.dart';
import '../models/album_model.dart';
import '../models/genre_model.dart';
import '../services/api_service.dart';

class SearchService {
  final   ApiService _apiService = ApiService();

// 1. Search songs+ artists
  Future<Map<String, dynamic>> searchAll(String query) async {
    if (query.trim().isEmpty) {
      return {
        'songs' : <SongModel>[],
        'artists' : <ArtistModel>[],
        'albums': <AlbumModel>[],
        'genres': <GenreModel>[],
      };
    }
// Gọi Api ApiConfig:  GET /search?q=<query>
    final response = await _apiService.get(
      ApiConfig.search,  // "/search"
      queryParams: {
        'q' : query,
      },
    );
// LẤY data TỪ response['data']
    final resdata = response['data'] as Map<String, dynamic>;
    print('Search response: $response');

//Parse songs
    final List<SongModel> songs = (resdata['songs'] as List<dynamic>?)
        ?.map((e) => SongModel.fromJson(e))
        .toList()??
        [];
//Parse artists
    final List<ArtistModel> artists = (resdata['artists'] as List<dynamic>?)
        ?.map((e) => ArtistModel.fromJson(e))
        .toList()??
        [];
//Parse albums
    final List<AlbumModel> albums = (resdata['albums'] as List<dynamic>?)
        ?.map((e) => AlbumModel.fromJson(e))
        .toList()??
        [];
//Parse genres
    final List<GenreModel> genres = (resdata['genres'] as List<dynamic>?)
        ?.map((e) => GenreModel.fromJson(e))
        .toList()??
        [];
    return {
      'songs' : songs,
      'artists' : artists,
      'albums' : albums,
      'genres' : genres,
    };
  }
//2. Search song : API GET /songs/search:
  Future<List<SongModel>> searchSongs(String query) async {
    final response = await _apiService.get(
      ApiConfig.songsSearch,
      queryParams: {'q': query},
    );

    return (response['songs'] as List<dynamic>?)
        ?.map((e) => SongModel.fromJson(e))
        .toList() ??
        [];
  }

  //3. Search  artists: API GET /artists/search:
  Future<List<ArtistModel>> searchArtists(String query) async {
    final response = await _apiService.get(
      ApiConfig.artistsSearch,
      queryParams: {'q': query},
    );

    return (response['artists'] as List<dynamic>?)
        ?.map((e) => ArtistModel.fromJson(e))
        .toList() ??
        [];
  }
}