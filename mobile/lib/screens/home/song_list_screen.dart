import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song_model.dart';
import '../../widgets/song_item.dart';
import '../../services/audio_player_service.dart';

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
              // Gọi AudioPlayerService để phát bài này
              // ignore: use_build_context_synchronously
              context.read<AudioPlayerService>().playSong(song);
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
