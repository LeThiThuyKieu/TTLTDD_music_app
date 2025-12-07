import '../models/song_model.dart';
import '../models/artist_model.dart';

class HomeApiService {
  /// Lấy trending songs (mock)
  Future<List<SongModel>> getTrendingSongs() async {
    await Future.delayed(const Duration(seconds: 1)); // Giả lập loading
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
          )
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
          )
        ],
      ),
    ];
  }

  /// Lấy popular artists (mock)
  Future<List<ArtistModel>> getPopularArtists() async {
    await Future.delayed(const Duration(seconds: 1));
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

  /// Lấy top charts (mock)
  Future<List<SongModel>> getTopCharts() async {
    await Future.delayed(const Duration(seconds: 1));
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
          )
        ],
      ),
      SongModel(
        songId: 4,
        title: "Kiss Me More",
        fileUrl: "https://www.example.com/songs/kiss_me_more.mp3",
        coverUrl: "https://i.imgur.com/3nYgB2l.jpg",
        duration: 210,
        artists: [
          ArtistModel(
            artistId: 4,
            name: "Doja Cat",
            avatarUrl: "https://i.pravatar.cc/150?img=4",
          )
        ],
      ),
    ];
  }
}
