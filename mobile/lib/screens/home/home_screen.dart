import 'package:flutter/material.dart';
import 'package:music_app/screens/home/music_player_screen.dart';

import '../../models/song_model.dart';
import '../../models/artist_model.dart';
import '../../models/album_model.dart';
import '../../services/home_api_service.dart';
import '../../services/auth_service.dart';
import '../../utils/toast.dart';
import '../../widgets/mini_player.dart';
import '../auth/login_screen.dart';
import 'song_list_screen.dart';
import 'package:provider/provider.dart';
import '../../services/audio_player_service.dart';
// Huong
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeApiService _homeApiService = HomeApiService();
  final AuthService _authService = AuthService();

  // Data cho từng section
  List<AlbumModel> hotAlbums = [];
  List<ArtistModel> popularArtists = [];
  List<SongModel> trendingSongs = [];

  bool isLoading = true;
  String? userName;
  String? avatarUrl;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
    _loadHomeData();
  }

  // Load thông tin user
  Future<void> _loadUserInfo() async {
    final name = await _authService.getUserName();
    final avatar = await _authService.getUserAvatar(); // có thể null

    setState(() {
      userName = name;
      avatarUrl = avatar;
    });
  }

  // logout
  Future<void> _handleLogout() async {
    final navigator = Navigator.of(context);

    showDialog(
      context: context,
      builder: (dialogContext) =>
          AlertDialog(
            title: const Text('Đăng xuất'),
            content: const Text('Bạn có chắc muốn đăng xuất không?'),
            actions: [
              TextButton(
                onPressed: () => navigator.pop(),
                child: const Text('Hủy'),
              ),
              TextButton(
                onPressed: () async {
                  navigator.pop(); // đóng dialog

                  await _authService.logout();

                  if (!mounted) return;

                  navigator.pushAndRemoveUntil(
                    MaterialPageRoute(builder: (_) => const LoginScreen()),
                        (route) => false,
                  );
                },
                child: const Text(
                  'Đăng xuất',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }

  // Load data cho Home
  Future<void> _loadHomeData() async {
    try {
      final albums = await _homeApiService.getHotAlbums();
      final artists = await _homeApiService.getPopularArtists();
      final songs = await _homeApiService.getTrendingSongs();

      setState(() {
        hotAlbums = albums;
        popularArtists = artists;
        trendingSongs = songs;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Load home error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SafeArea(
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

                const SizedBox(height: 100), // chừa chỗ cho mini player
              ],
            ),
          ),

          // MINI PLAYER NẰM DƯỚI (nghe nhạc mini)
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: MiniPlayer(),
          ),
        ],
      ),
    );
  }

  // ================= HEADER =================
  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade300,
          backgroundImage: (avatarUrl != null && avatarUrl!.startsWith('http'))
              ? NetworkImage(avatarUrl!)
              : null,
          child: (avatarUrl == null || !avatarUrl!.startsWith('http'))
              ? const Icon(
            Icons.person,
            color: Colors.white,
            size: 26,
          )
              : null,
        ),
        const SizedBox(width: 12),
        Text(
          'Hi 👋 ${userName ?? 'User'}',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const Spacer(),
        const Icon(Icons.search),
        const SizedBox(width: 16),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _handleLogout,
        ),
      ],
    );
  }

  // ================= SECTION HEADER =================
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

  // ================= ALBUM LIST =================
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

  // ================= ARTIST LIST =================
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

  // ================= SONG LIST =================
  // Danh sách nhạc (song) hot thịnh hành (có nút play)
  Widget _buildSongList() {
    return SizedBox(
      height: 230,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: trendingSongs.length,
        itemBuilder: (context, index) {
          final song = trendingSongs[index];
          return Container(
              width: 150,
              margin: const EdgeInsets.only(right: 16),
              child: GestureDetector(
                onTap: () {
                  // 1️⃣ Mở MusicPlayerScreen khi bấm vào item
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MusicPlayerScreen(),
                    ),
                  );
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ẢNH + NÚT PLAY
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          // Ảnh bài hát
                          Image.network(
                            song.coverUrl ?? '',
                            height: 150,
                            width: 150,
                            fit: BoxFit.cover,
                          ),

                          // Nút play
                          Positioned(
                            bottom: 5,
                            right: 5,
                            child: GestureDetector(
                              onTap: () {
                                // TODO: Gọi AudioPlayerService.playSong(song)
                                // debugPrint('Play song: ${song.songId}');
                                context.read<AudioPlayerService>().playSong(
                                    song);
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
                    // Tên bài hát
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    // Tên nghệ sĩ
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
        builder: (_) => SongListScreen(songs: trendingSongs),
      ),
    );
  }
}
