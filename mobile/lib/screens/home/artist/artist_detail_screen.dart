import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/artist_model.dart';
import '../../../models/song_model.dart';
import '../../../services/audio_player_service.dart';
import '../../../widgets/song_item.dart';
import '../song_list_screen.dart';

class ArtistDetailScreen extends StatelessWidget {
  final ArtistModel artist;
  final List<SongModel> popularSongs;

  const ArtistDetailScreen({
    super.key,
    required this.artist,
    required this.popularSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===== bar =====
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ===== avatar =====
            ClipOval(
              child: Image.network(
                artist.avatarUrl ?? '',
                width: 180,
                height: 180,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 180,
                  height: 180,
                  color: Colors.grey.shade300,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.person,
                    size: 64,
                    color: Colors.white,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ===== name =====
            Text(
              artist.name,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 6),

            // ===== description =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                artist.description ?? 'No description',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
              ),
            ),

            const SizedBox(height: 28),

            // ===== popular song header =====
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Popular Songs',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => SongListScreen(songs: popularSongs),
                        ),
                      );
                    },
                    child: const Text(
                      'See All',
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // ===== Danh sách bài hát của artist đó =====
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: popularSongs.length > 5 ? 5 : popularSongs.length,
              itemBuilder: (context, index) {
                final song = popularSongs[index];

                return SongItem(
                  song: song,
                  onPlay: () {
                    context.read<AudioPlayerService>().playSong(song);
                  },
                  onTap: () {
                    debugPrint('Open song: ${song.title}');
                  },
                );
              },
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
