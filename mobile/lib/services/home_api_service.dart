import '../models/song_model.dart';
import '../models/artist_model.dart';
import '../models/album_model.dart';
import 'api_service.dart';

class HomeApiService {
  final ApiService _apiService = ApiService();

  // Lấy ra albums hot (giả lập trực tiếp)
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

  // Lấy ra nghệ sĩ nổi bật (giả lập trực tiếp)
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

  // Lấy ra nhạc hot thịnh hành (giả lập trực tiếp)
  // ======= Kiều có sửa chỗ này để thử lấy ds songs nha Hương (có j H sửa lại) ======
  Future<List<SongModel>> getTrendingSongs() async {
    final response=await _apiService.get(
      '/songs',
      queryParams: {
        'limit':'10',
      },
      includeAuth: true, // optionalAuth bên backend
    );
    final List listSongs=response['data'];
    return listSongs.map((e) => SongModel.fromJson(e)).toList();
  }

}
