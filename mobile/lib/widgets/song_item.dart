import 'package:flutter/material.dart';
import '../models/song_model.dart';

class SongItem extends StatelessWidget {
  final SongModel song;

  /// callback khi bấm play
  final VoidCallback? onPlay;

  /// callback khi bấm vào item
  final VoidCallback? onTap;

  const SongItem({
    super.key,
    required this.song,
    this.onPlay,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // ===== ẢNH BÀI HÁT =====
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          song.coverUrl ?? '',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) =>
          const Icon(Icons.music_note, size: 40),
        ),
      ),

      // ===== TÊN BÀI HÁT =====
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      // ===== CA SĨ =====
      subtitle: Text(
        song.artists?.map((e) => e.name).join(', ') ?? 'Unknown artist',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),

      // ===== NÚT BÊN PHẢI =====
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Nút play
          IconButton(
            icon: const Icon(
              Icons.play_circle_fill,
              color: Colors.green,
              size: 28,
            ),
            onPressed: onPlay,
          ),

          // Nút more
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // mở bottom sheet / menu sau
            },
          ),
        ],
      ),

      // ===== TAP VÀO ITEM =====
      onTap: onTap,
    );
  }
}
