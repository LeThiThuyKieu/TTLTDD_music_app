import 'package:flutter/material.dart';

import '../models/song_model.dart';
import '../models/artist_model.dart';
import '../models/album_model.dart';
import '../services/home_api_service.dart';
import '../widgets/app_bottom_nav.dart';
import 'song_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeApiService _api = HomeApiService();

  /// Data cho từng section
  List<SongModel> topCharts = [];
  List<ArtistModel> popularArtists = [];
  List<AlbumModel> hotAlbums = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHomeData();
  }

  /// Load data cho Home
  Future<void> _loadHomeData() async {
    try {
      final charts = await _api.getTopCharts();
      final artists = await _api.getPopularArtists();
      final albums = await _api.getHotAlbums();

      setState(() {
        topCharts = charts;
        popularArtists = artists;
        hotAlbums = albums;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Load home error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {},
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
        )
            : ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 20),
            _buildHeader(),

            const SizedBox(height: 30),
            _buildSectionHeader(
              title: 'Album hot',
              onSeeMore: () {},
            ),
            const SizedBox(height: 12),
            _buildAlbumList(),

            const SizedBox(height: 30),
            _buildSectionHeader(
              title: 'Nghệ sĩ nổi bật',
              onSeeMore: () {},
            ),
            const SizedBox(height: 12),
            _buildArtistList(),

            const SizedBox(height: 30),
            _buildSectionHeader(
              title: 'Nhạc hot thịnh hành',
              onSeeMore: _openAllSongs,
            ),
            const SizedBox(height: 12),
            _buildSongList(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  /// ================= HEADER =================
  Widget _buildHeader() {
    return Row(
      children: const [
        CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=3'),
        ),
        SizedBox(width: 12),
        Text(
          'Hi 👋 Andrew',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        Spacer(),
        Icon(Icons.search),
        SizedBox(width: 16),
        Icon(Icons.notifications_none),
      ],
    );
  }

  /// ================= SECTION HEADER =================
  Widget _buildSectionHeader({
    required String title,
    required VoidCallback onSeeMore,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
          ),
        ),
        GestureDetector(
          onTap: onSeeMore,
          child: const Text(
            'Xem thêm',
            style: TextStyle(
              color: Color(0xFF4CAF50),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  /// ================= ALBUM LIST =================
  Widget _buildAlbumList() {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: hotAlbums.length,
        itemBuilder: (context, index) {
          final album = hotAlbums[index];
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    album.coverUrl ?? '',
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  album.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ================= ARTIST LIST =================
  Widget _buildArtistList() {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: popularArtists.length,
        itemBuilder: (context, index) {
          final artist = popularArtists[index];
          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(artist.avatarUrl ?? ''),
                ),
                const SizedBox(height: 8),
                Text(
                  artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ================= SONG LIST =================
  /// ================= SONG LIST =================
  /// Danh sách bài hát thịnh hành (có nút play)
  Widget _buildSongList() {
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: topCharts.length,
        itemBuilder: (context, index) {
          final song = topCharts[index];

          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// ẢNH + NÚT PLAY
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Stack(
                    children: [
                      /// Ảnh bài hát
                      Image.network(
                        song.coverUrl ?? 'https://via.placeholder.com/150',
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),

                      /// Nút play
                      Positioned(
                        bottom: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () {
                            // TODO: Gọi AudioPlayerService.playSong(song)
                            debugPrint('Play song: ${song.songId}');
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: const BoxDecoration(
                              color: Color(0xFF8D918D),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 8),

                /// Tên bài hát
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                /// Nghệ sĩ
                Text(
                  song.artists != null && song.artists!.isNotEmpty
                      ? song.artists!.first.name
                      : 'Unknown Artist',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }


  /// ================= SEE MORE SONGS =================
  void _openAllSongs() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SongListScreen(songs: topCharts),
      ),
    );
  }
}
