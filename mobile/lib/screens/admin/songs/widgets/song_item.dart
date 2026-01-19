import 'package:flutter/material.dart';
import '../../../../models/song_model.dart';

class SongItem extends StatelessWidget {
  final SongModel song;
  final VoidCallback? onDelete;

  const SongItem({
    Key? key,
    required this.song,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final active = song.isActive == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          /// IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              song.coverUrl ?? '',
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 44,
                height: 44,
                color: Colors.grey.shade300,
                child: const Icon(Icons.music_note),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  song.artistNames,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),

          Text(
            active ? 'Active' : 'Unactive',
            style: TextStyle(
              fontSize: 12,
              color: active ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),

          IconButton(
            icon: const Icon(Icons.delete_outline,
                color: Color(0xFF8DB27C)),
            onPressed: onDelete == null
                ? null
                : () => _showDeleteDialog(context),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá bài hát'),
        content: Text('Bạn có chắc muốn xoá "${song.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
            ),
            onPressed: () {
              Navigator.pop(context);
              onDelete?.call();
            },
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}
