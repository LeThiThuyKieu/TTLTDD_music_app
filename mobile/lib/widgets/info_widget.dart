import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import 'package:provider/provider.dart';

class InfoWidget extends StatelessWidget {
  final SongModel song;

  const InfoWidget({super.key, required this.song});

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioPlayerService>();
    final playlist = audio.currentPlaylist; // List<SongModel>?

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎵 Tên bài hát
          Text(
            song.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // 🎤 Nghệ sĩ
          Text(
            song.artists.map((e) => e.name).join(', '),
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),

          const SizedBox(height: 12),

          // 📂 Danh sách phát (Queue)
          if (playlist != null && playlist.isNotEmpty)
            GestureDetector(
              onTap: () => _showPlaylist(context, playlist),
              child: const Row(
                children: [
                  Icon(Icons.queue_music,
                      color: Colors.white70, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Danh sách phát',
                    style: TextStyle(
                      color: Colors.white70,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ================== BOTTOM SHEET PLAYLIST ==================
  void _showPlaylist(BuildContext context, List<SongModel> playlist) {
    final audio = context.read<AudioPlayerService>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView.builder(
        itemCount: playlist.length,
        itemBuilder: (context, index) {
          final song = playlist[index];
          final isCurrent = index == audio.currentIndex;

          return ListTile(
            leading: Icon(
              isCurrent ? Icons.play_arrow : Icons.music_note,
              color: isCurrent ? Colors.blue : Colors.white70,
            ),
            title: Text(
              song.title,
              style: TextStyle(
                color: isCurrent ? Colors.blue : Colors.white,
                fontWeight:
                isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              song.artists.map((e) => e.name).join(', '),
              style: const TextStyle(color: Colors.white54),
            ),
            onTap: () {
              audio.playSongFromPlaylist(playlist, index);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}


