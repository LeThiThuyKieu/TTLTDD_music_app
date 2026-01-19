import 'package:flutter/material.dart';
import '../../../../models/song_model.dart';
import 'song_item.dart';

class SongCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<SongModel> songs;
  final void Function(SongModel)? onDelete;

  const SongCard({
    Key? key,
    required this.title,
    required this.icon,
    required this.songs,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F6F1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.black12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (songs.isEmpty)
            const Text(
              'Không có bài hát',
              style: TextStyle(color: Colors.black54),
            )
          else
            ...songs.map(
                  (song) => SongItem(
                song: song,
                onDelete: () => onDelete?.call(song),
              ),
            ),
        ],
      ),
    );
  }
}
