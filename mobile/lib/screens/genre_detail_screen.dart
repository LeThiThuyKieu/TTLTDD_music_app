import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/genre_model.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import '../services/genre_api_service.dart';
import '../widgets/song_item.dart';
import '../widgets/scaffold_with_mini_player.dart';
import 'home/music_player_screen.dart';

class GenreDetailScreen extends StatefulWidget {
  final int genreId;
  final String? genreName;

  const GenreDetailScreen({
    super.key,
    required this.genreId,
    this.genreName,
  });

  @override
  State<GenreDetailScreen> createState() => _GenreDetailScreenState();
}

class _GenreDetailScreenState extends State<GenreDetailScreen> {
  bool _loading = true;
  String? _error;

  GenreModel? _genre;
  List<SongModel> _songs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // 1) Lấy genre (nếu API có)
      GenreModel g;
      try {
        g = await GenreApiService.instance.getGenre(widget.genreId);
      } catch (_) {
        // fallback: vẫn có tên để UI đẹp
        g = GenreModel(
          genreId: widget.genreId,
          name: widget.genreName ?? "Genre",
        );
      }

      // 2) Lấy bài theo genre (đúng route BE: /songs/genre/:genreId)
      final songs = await GenreApiService.instance.getSongsByGenre(
        widget.genreId,
        limit: 50,
        offset: 0,
      );

      if (!mounted) return;
      setState(() {
        _genre = g;
        _songs = songs;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  // ---- helpers để lấy mô tả/ảnh nếu model có field ----
  String _genreDescription(GenreModel g) {
    // Nếu bạn có field description trong GenreModel thì tự động dùng
    try {
      final dynamic any = g;
      final String? des = any.description as String?;
      if (des != null && des.trim().isNotEmpty) return des.trim();
    } catch (_) {}
    return "Thể loại âm nhạc";
  }

  String? _genreImageUrl(GenreModel g) {
    // Nếu model có image/coverUrl/avatarUrl thì tự lấy
    try {
      final dynamic any = g;
      final String? url = any.coverUrl as String?;
      if (url != null && url.trim().isNotEmpty) return url.trim();
    } catch (_) {}

    try {
      final dynamic any = g;
      final String? url = any.cover_url as String?;
      if (url != null && url.trim().isNotEmpty) return url.trim();
    } catch (_) {}

    try {
      final dynamic any = g;
      final String? url = any.avatarUrl as String?;
      if (url != null && url.trim().isNotEmpty) return url.trim();
    } catch (_) {}

    try {
      final dynamic any = g;
      final String? url = any.avatar_url as String?;
      if (url != null && url.trim().isNotEmpty) return url.trim();
    } catch (_) {}

    return null;
  }

  @override
  Widget build(BuildContext context) {
    final genre = _genre;
    final title = genre?.name ?? widget.genreName ?? "Genre";
    final audioPlayer = context.watch<AudioPlayerService>();
    final hasSong = audioPlayer.currentSong != null;

    return ScaffoldWithMiniPlayer(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        foregroundColor: Colors.black,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Lỗi: $_error"))
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 8, 16, hasSong ? 80 : 24),
          children: [
            const SizedBox(height: 10),

            // Avatar tròn (giống artist detail)
            Center(
              child: _CircleAvatar(
                size: 160,
                imageUrl: genre != null ? _genreImageUrl(genre) : null,
                fallbackIcon: Icons.queue_music,
              ),
            ),

            const SizedBox(height: 14),

            Center(
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),

            const SizedBox(height: 6),

            Center(
              child: Text(
                genre != null ? _genreDescription(genre) : "Thể loại âm nhạc",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  color: Colors.black54,
                ),
              ),
            ),

            const SizedBox(height: 18),

            Row(
              children: [
                const Text(
                  "Bài hát",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _songs.isEmpty
                      ? null
                      : () => _snack("Tổng: ${_songs.length} bài"),
                  child: const Text(
                    "Xem tất cả",
                    style: TextStyle(
                      color: Color(0xFF1DB954),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            if (_songs.isEmpty)
              _EmptyCard(message: "Chưa có bài hát cho thể loại: $title")
            else
              Column(
                children: _songs
                    .take(20)
                    .map(
                      (s) => Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 14,
                          offset: const Offset(0, 8),
                        )
                      ],
                    ),
                    child: SongItem(
                      song: s,
                      onPlay: () => context
                          .read<AudioPlayerService>()
                          .playSong(s),
                      onTap: () {
                        context
                            .read<AudioPlayerService>()
                            .playSong(s);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const MusicPlayerScreen(),
                          ),
                        );
                      },
                    ),
                      ),
                )
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }
}

class _CircleAvatar extends StatelessWidget {
  final double size;
  final String? imageUrl;
  final IconData fallbackIcon;

  const _CircleAvatar({
    required this.size,
    required this.imageUrl,
    required this.fallbackIcon,
  });

  @override
  Widget build(BuildContext context) {
    final url = (imageUrl ?? "").trim();

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: const Color(0xFFF1F3F5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 18,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: url.isEmpty
          ? Icon(fallbackIcon, size: 54, color: Colors.black38)
          : Image.network(
        url,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            Icon(fallbackIcon, size: 54, color: Colors.black38),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String message;
  const _EmptyCard({required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F7F9),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Icon(Icons.music_off, size: 46, color: Colors.black38),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 42,
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Hiện chưa có bài trong thể loại này")),
                );
              },
              icon: const Icon(Icons.info_outline),
              label: const Text("Thông báo"),
              style: OutlinedButton.styleFrom(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
