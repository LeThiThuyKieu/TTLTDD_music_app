import 'package:flutter/material.dart';
import '../../../../models/song_model.dart';

class SongItemWidget extends StatelessWidget {
  final SongModel song;

  const SongItemWidget({
    Key? key,
    required this.song,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final artistNames =
        song.artists?.map((a) => a.name).join(', ') ?? 'Unknown Artist';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          /// ===== COVER IMAGE =====
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.network(
              song.coverUrl ??
                  'https://via.placeholder.com/150', // fallback
              width: 54,
              height: 54,
              fit: BoxFit.cover,
            ),
          ),

          const SizedBox(width: 12),

          /// ===== TITLE + SUBTITLE =====
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$artistNames • Song',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          /// ===== PLAY BUTTON =====
          IconButton(
            icon: const Icon(
              Icons.play_circle_fill,
              color: Color(0xFF1DB954), // xanh Spotify
              size: 34,
            ),
            onPressed: () {
              // TODO: play song
            },
          ),
        ],
      ),
    );
  }
}
