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
    // final response = await _apiService.get(
    //   '/albums',
    //   queryParams: {'limit': '10'},
    //   includeAuth: true,
    // );
    //
    // final List list = response['data'];
    // return list.map((e) => AlbumModel.fromJson(e)).toList();
  }

  // Lấy ra nghệ sĩ nổi bật
  Future<List<ArtistModel>> getPopularArtists() async {
    final response = await _apiService.get(
      '/artists',
      queryParams: {'limit': '10'},
      includeAuth: true,
    );
    final List list = response['data'];
    return list.map((e) => ArtistModel.fromJson(e)).toList();
  }

  // Lấy ra nhạc hot thịnh hành
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
