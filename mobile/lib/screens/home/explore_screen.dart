import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/genre_model.dart';
import '../../services/genre_api_service.dart';
import '../../services/audio_player_service.dart';
import '../genre_detail_screen.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  bool _loading = true;
  String? _error;
  List<GenreModel> _genres = [];

  @override
  void initState() {
    super.initState();
    _loadGenres();
  }

  Future<void> _loadGenres() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await GenreApiService.instance.getGenres();
      setState(() {
        _genres = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  // ✅ Nếu GenreModel của bạn đã có genreId thì dùng thẳng: g.genreId
  // Giữ hàm này để tránh crash nếu model chưa đồng nhất.
  int? _genreIdOf(GenreModel g) {
    try {
      final dynamic any = g;
      final int? id = any.genreId as int?;
      if (id != null) return id;
    } catch (_) {}

    try {
      final dynamic any = g;
      final int? id = any.id as int?;
      if (id != null) return id;
    } catch (_) {}

    return null;
  }

  Color _tileColor(int i) {
    const colors = [
      Color(0xFF22C55E),
      Color(0xFF8B5CF6),
      Color(0xFFF59E0B),
      Color(0xFF3B82F6),
      Color(0xFFEF4444),
      Color(0xFFF97316),
      Color(0xFF14B8A6),
      Color(0xFF6B7280),
    ];
    return colors[i % colors.length];
  }

  IconData _tileIcon(String name) {
    final n = name.toLowerCase();
    if (n.contains("pop")) return Icons.music_note;
    if (n.contains("rap") || n.contains("hip")) return Icons.graphic_eq;
    if (n.contains("rock")) return Icons.headphones;
    if (n.contains("ballad") || n.contains("romance")) return Icons.favorite;
    if (n.contains("r&b")) return Icons.album;
    return Icons.category;
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayer = context.watch<AudioPlayerService>();
    final hasSong = audioPlayer.currentSong != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F7),
        elevation: 0,
        title: const Text(
          "Explore",
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
        ),
        actions: const [SizedBox(width: 8)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Lỗi: $_error"))
          : RefreshIndicator(
        onRefresh: _loadGenres,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 12, 16, hasSong ? 80 : 16),
          children: [
            Container(
              height: 42,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(Icons.search, color: Colors.black38),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Artists, Songs, Rockwell, & more",
                      style: TextStyle(color: Colors.black38),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            const Text(
              "Browse All",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 10),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _genres.length,
              gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, i) {
                final g = _genres[i];
                final color = _tileColor(i);

                return InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    final id = _genreIdOf(g);
                    if (id == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Genre không có id hợp lệ"),
                        ),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => GenreDetailScreen(
                          genreId: id,
                          genreName: g.name,
                        ),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: color,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Stack(
                      children: [
                        Align(
                          alignment: Alignment.topLeft,
                          child: Text(
                            g.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w900,
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.bottomRight,
                          child: Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              _tileIcon(g.name),
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
