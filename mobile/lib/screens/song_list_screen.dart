import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../widgets/song_item.dart';

class SongListScreen extends StatelessWidget {
  final List<SongModel> songs;

  const SongListScreen({
    super.key,
    required this.songs,
  });

  @override
  Widget build(BuildContext context) {
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
          );
        },
      ),
    );
  }
}
