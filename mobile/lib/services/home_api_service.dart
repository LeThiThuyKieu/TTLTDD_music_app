
// import 'package:http/http.dart' as http;
import '../models/song_model.dart';
import '../models/artist_model.dart';
import '../models/album_model.dart';

// class HomeApiService {
//   final String baseUrl = "https://your-backend.com/api"; // đổi thành URL thực tế
//
//   /// Lấy trending songs từ BE
//   Future<List<SongModel>> getTrendingSongs() async {
//     final res = await http.get(Uri.parse("$baseUrl/trending-songs"));
//     if (res.statusCode == 200) {
//       final List data = json.decode(res.body);
//       return data.map((json) => SongModel.fromJson(json)).toList();
//     } else {
//       throw Exception("Failed to load trending songs");
//     }
//   }
//
//   /// Lấy popular artists từ BE
//   Future<List<ArtistModel>> getPopularArtists() async {
//     final res = await http.get(Uri.parse("$baseUrl/popular-artists"));
//     if (res.statusCode == 200) {
//       final List data = json.decode(res.body);
//       return data.map((json) => ArtistModel.fromJson(json)).toList();
//     } else {
//       throw Exception("Failed to load popular artists");
//     }
//   }
//
//   /// Lấy top charts từ BE
//   Future<List<SongModel>> getTopCharts() async {
//     final res = await http.get(Uri.parse("$baseUrl/top-charts"));
//     if (res.statusCode == 200) {
//       final List data = json.decode(res.body);
//       return data.map((json) => SongModel.fromJson(json)).toList();
//     } else {
//       throw Exception("Failed to load top charts");
//     }
//   }
//
//   /// Lấy album hot từ BE
//   Future<List<AlbumModel>> getHotAlbums() async {
//     final res = await http.get(Uri.parse("$baseUrl/hot-albums"));
//     if (res.statusCode == 200) {
//       final List data = json.decode(res.body);
//       return data.map((json) => AlbumModel.fromJson(json)).toList();
//     } else {
//       throw Exception("Failed to load hot albums");
//     }
//   }
// }

class HomeApiService {
  /// Lấy trending songs (giả lập trực tiếp)
  Future<List<SongModel>> getTrendingSongs() async {
    await Future.delayed(const Duration(milliseconds: 500)); // giả lập loading
    return [
      SongModel(
        songId: 1,
        title: "Blinding Lights",
        fileUrl: "https://www.example.com/songs/blinding_lights.mp3",
        coverUrl: "https://i.imgur.com/0f5Yw5h.jpg",
        duration: 200,
        artists: [
          ArtistModel(
            artistId: 1,
            name: "The Weeknd",
            avatarUrl: "https://i.pravatar.cc/150?img=1",
          ),
        ],
      ),
      SongModel(
        songId: 2,
        title: "Levitating",
        fileUrl: "https://www.example.com/songs/levitating.mp3",
        coverUrl: "https://i.imgur.com/2nCt3Sbl.jpg",
        duration: 203,
        artists: [
          ArtistModel(
            artistId: 2,
            name: "Dua Lipa",
            avatarUrl: "https://i.pravatar.cc/150?img=2",
          ),
        ],
      ),
    ];
  }

  /// Lấy popular artists (giả lập trực tiếp)
  Future<List<ArtistModel>> getPopularArtists() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      ArtistModel(
        artistId: 1,
        name: "The Weeknd",
        avatarUrl: "https://i.pravatar.cc/150?img=1",
      ),
      ArtistModel(
        artistId: 2,
        name: "Dua Lipa",
        avatarUrl: "https://i.pravatar.cc/150?img=2",
      ),
      ArtistModel(
        artistId: 3,
        name: "Justin Bieber",
        avatarUrl: "https://i.pravatar.cc/150?img=3",
      ),
    ];
  }

  /// Lấy top charts (giả lập trực tiếp)
  Future<List<SongModel>> getTopCharts() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      SongModel(
        songId: 3,
        title: "Save Your Tears",
        fileUrl: "https://www.example.com/songs/save_your_tears.mp3",
        coverUrl: "https://i.imgur.com/0f5Yw5h.jpg",
        duration: 215,
        artists: [
          ArtistModel(
            artistId: 1,
            name: "The Weeknd",
            avatarUrl: "https://i.pravatar.cc/150?img=1",
          ),
        ],
      ),
    ];
  }

  /// Lấy hot albums (giả lập trực tiếp)
  Future<List<AlbumModel>> getHotAlbums() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return [
      AlbumModel(
        albumId: 1,
        title: "After Hours",
        coverUrl: "https://i.imgur.com/0f5Yw5h.jpg",
        artist: ArtistModel(
          artistId: 1,
          name: "The Weeknd",
          avatarUrl: "https://i.pravatar.cc/150?img=1",
        ),
      ),
      AlbumModel(
        albumId: 2,
        title: "Future Nostalgia",
        coverUrl: "https://i.imgur.com/2nCt3Sbl.jpg",
        artist: ArtistModel(
          artistId: 2,
          name: "Dua Lipa",
          avatarUrl: "https://i.pravatar.cc/150?img=2",
        ),
      ),
    ];
  }
}
