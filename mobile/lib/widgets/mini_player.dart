import 'package:flutter/material.dart';
import 'package:music_app/screens/home/music_player_screen.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';

class MiniPlayer extends StatefulWidget {
  const MiniPlayer({super.key});

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  /// FE-only: trạng thái yêu thích
  bool _isLiked = false;

  @override
  Widget build(BuildContext context) {
    return Consumer<AudioPlayerService>(
      builder: (context, player, _) {
        if (player.currentSong == null) return const SizedBox();

        final song = player.currentSong!;
        return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MusicPlayerScreen(), // màn hình trình phát đầy đủ
                ),
              );
            },
        child: Container(
          height: 60,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.12),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: Row(
            children: [
              /// Ảnh bài hát
              CircleAvatar(
                radius: 22,
                backgroundImage:
                song.coverUrl != null && song.coverUrl!.isNotEmpty
                    ? NetworkImage(song.coverUrl!)
                    : null,
                backgroundColor: Colors.grey[800],
                child: song.coverUrl == null || song.coverUrl!.isEmpty
                    ? const Icon(Icons.music_note, color: Colors.white)
                    : null,
              ),

              const SizedBox(width: 12),

              /// Tên bài hát + nghệ sĩ
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      song.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      song.artists?.map((e) => e.name).join(', ') ??
                          'Unknown artist',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),

              /// Previous
              IconButton(
                icon: const Icon(Icons.skip_previous),
                onPressed: () {},
              ),

              /// Play / Pause
              IconButton(
                icon: Icon(
                  player.isPlaying ? Icons.pause : Icons.play_arrow,
                  size: 28,
                ),
                onPressed: () {
                  player.isPlaying ? player.pause() : player.resume();
                },
              ),

              /// Next
              IconButton(
                icon: const Icon(Icons.skip_next),
                onPressed: () {},
              ),

              /// ❤️ LIKE BUTTON
              IconButton(
                icon: Icon(
                  _isLiked ? Icons.favorite : Icons.favorite_border,
                  color: _isLiked ? Colors.red : Colors.black87,
                ),
                onPressed: () {
                  setState(() {
                    _isLiked = !_isLiked;
                  });
                },
              ),
            ],
          ),
        ),);
      },
    );
  }
}
