import 'package:flutter/material.dart';

import '../models/genre_model.dart';
import '../models/song_model.dart';
import '../services/genre_api_service.dart';
import '../widgets/song_item.dart';

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
      // ✅ Fallback genre (vì service bạn chưa có getGenreById)
      final g = GenreModel(
        genreId: widget.genreId,
        name: widget.genreName ?? "Genre",
      );

      // ✅ Hiện tại service bạn cũng chưa có getSongsByGenre
      // -> để tránh lỗi đỏ, ta tạm cho list rỗng (UI vẫn chạy)
      final List<SongModel> list = [];

      setState(() {
        _genre = g;
        _songs = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final title = _genre?.name ?? widget.genreName ?? "Genre";

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF5F6F7),
        elevation: 0,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w900, color: Colors.black87),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Lỗi: $_error"))
          : RefreshIndicator(
        onRefresh: _load,
        child: _songs.isEmpty
            ? ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 36),
            const Icon(Icons.music_off, size: 48, color: Colors.black26),
            const SizedBox(height: 10),
            Center(
              child: Text(
                "Chưa có bài hát cho thể loại: $title",
                style: const TextStyle(color: Colors.black54),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () => _snack("Bạn cần implement API songs theo genre"),
              icon: const Icon(Icons.info_outline),
              label: const Text("Thông báo"),
            ),
          ],
        )
            : ListView.separated(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: _songs.length,
          separatorBuilder: (_, __) => const SizedBox(height: 10),
          itemBuilder: (_, i) {
            final s = _songs[i];
            return SongItem(
              song: s,
              onTap: () => _snack("Tap: ${s.title}"),
            );
          },
        ),
      ),
    );
  }
}
