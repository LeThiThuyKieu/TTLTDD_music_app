import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../models/artist_model.dart';
import '../services/home_api_service.dart';

// TODO: Import widget BottomNavigationBar tái sử dụng
import '../widgets/app_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final HomeApiService _api = HomeApiService();

  List<SongModel> trendingSongs = [];
  List<ArtistModel> popularArtists = [];
  List<SongModel> topCharts = [];

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final trending = await _api.getTrendingSongs();
      final artists = await _api.getPopularArtists();
      final charts = await _api.getTopCharts();

      setState(() {
        trendingSongs = trending;
        popularArtists = artists;
        topCharts = charts;
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error loading home data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // Đưa AppBottomNav
      bottomNavigationBar: AppBottomNav(
        currentIndex: 0,
        onTap: (index) {
          // TODO: Xử lý khi chọn tab nếu cần
          debugPrint("Selected tab: $index");
        },
      ),


      body: SafeArea(
        child: isLoading
            ? const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF4CAF50),
          ),
        )
            : ListView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: [
            const SizedBox(height: 20),
            _buildHeader(),
            const SizedBox(height: 30),
            _buildSectionHeader("Nhạc hot thịnh hành"),
            const SizedBox(height: 12),
            _buildSongList(trendingSongs),
            const SizedBox(height: 30),
            _buildSectionHeader("Nghệ sĩ nổi bật"),
            const SizedBox(height: 12),
            _buildArtistList(popularArtists),
            const SizedBox(height: 30),
            _buildSectionHeader("Bảng xếp hạng"),
            const SizedBox(height: 12),
            _buildSongList(topCharts),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
          backgroundImage: NetworkImage("https://i.pravatar.cc/150?img=3"),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text("Hi 👋",
                style: TextStyle(fontSize: 14, color: Colors.black54)),
            Text("Andrew Ainsley",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
        const Spacer(),
        const Icon(Icons.search, size: 26),
        const SizedBox(width: 14),
        const Icon(Icons.notifications_none, size: 26),
      ],
    );
  }

  Widget _buildSectionHeader(String title) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title,
            style: const TextStyle(
                fontSize: 20, fontWeight: FontWeight.w700, color: Colors.black87)),
        const Text("Xem thêm",
            style: TextStyle(
                fontSize: 14,
                color: Color(0xFF4CAF50),
                fontWeight: FontWeight.w500)),
      ],
    );
  }

  /// SONG LIST
  Widget _buildSongList(List<SongModel> songs) {
    return SizedBox(
      height: 210,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final s = songs[index];
          final artistName = s.artists != null && s.artists!.isNotEmpty
              ? s.artists!.first.name
              : "Unknown Artist";
          return Container(
            width: 150,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(
                    s.coverUrl != null && s.coverUrl!.isNotEmpty
                        ? s.coverUrl!
                        : 'https://via.placeholder.com/150',
                    height: 150,
                    width: 150,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 8),
                Text(s.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                Text(artistName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: Colors.black54)),
              ],
            ),
          );
        },
      ),
    );
  }

  /// ARTIST LIST
  Widget _buildArtistList(List<ArtistModel> artists) {
    return SizedBox(
      height: 120,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: artists.length,
        itemBuilder: (context, index) {
          final a = artists[index];
          return Container(
            width: 90,
            margin: const EdgeInsets.only(right: 16),
            child: Column(
              children: [
                CircleAvatar(
                  radius: 32,
                  backgroundImage: NetworkImage(
                    a.avatarUrl != null && a.avatarUrl!.isNotEmpty
                        ? a.avatarUrl!
                        : 'https://via.placeholder.com/150',
                  ),
                ),
                const SizedBox(height: 8),
                Text(a.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontWeight: FontWeight.w500)),
              ],
            ),
          );
        },
      ),
    );
  }
}
