import 'package:flutter/material.dart';
import '../models/song_model.dart';

/// Trả về `true` nếu có thay đổi favorite
Future<bool?> showSongActionSheet(
    BuildContext context, {
      required SongModel song,
      required bool isFavorite,
      Future<void> Function()? onToggleFavorite,
      VoidCallback? onAddToPlaylist,
    }) async {
  return await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) {
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// ❤️ FAVORITE
            ListTile(
              leading: Icon(
                isFavorite ? Icons.favorite : Icons.favorite_border,
                color: isFavorite ? Colors.red : null,
              ),
              title: Text(
                isFavorite ? 'Bỏ yêu thích' : 'Thêm vào yêu thích',
              ),
              onTap: onToggleFavorite == null
                  ? null
                  : () async {
                await onToggleFavorite();

                if (context.mounted) {
                  /// báo cho màn hình gọi biết là đã thay đổi
                  Navigator.pop(context, true);
                }
              },
            ),

            /// ➕ ADD TO PLAYLIST
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text('Thêm vào playlist'),
              onTap: () {
                Navigator.pop(context);
                onAddToPlaylist?.call();
              },
            ),

            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}
