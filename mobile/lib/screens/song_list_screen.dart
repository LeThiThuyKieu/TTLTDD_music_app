import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../widgets/song_item.dart';
import '../widgets/add_to_playlist_sheet.dart';
import '../services/favorite_api_service.dart';

class SongListScreen extends StatefulWidget {
  final List<SongModel> songs;

  const SongListScreen({
    super.key,
    required this.songs,
  });

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  @override
  void initState() {
    super.initState();
    // Load favorites để icon tim hiển thị đúng
    FavoriteApiService.instance.loadFavorites().catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final songs = widget.songs;

    return Scaffold(
      // ===== APP BAR =====
      appBar: AppBar(
        title: const Text('Bài hát'),
        centerTitle: false,
      ),

      // ===== DANH SÁCH BÀI HÁT =====
      body: ListView.builder(
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];

          return SongItem(
            song: song,

            // bấm play
            onPlay: () {
              // TODO: gọi AudioPlayerService.play(song)
              debugPrint('Play: ${song.title}');
            },

            // bấm vào item
            onTap: () {
              // TODO: mở mini / full player
              debugPrint('Open player: ${song.title}');
            },

            // bấm "Thêm vào playlist" (từ menu more)
            onAddToPlaylist: () {
              showAddToPlaylistSheet(context, song);
            },
          );
        },
      ),
    );
  }
}
