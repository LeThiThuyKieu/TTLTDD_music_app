import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/favorite_api_service.dart';
import '../widgets/song_action_sheet.dart';

class SongItem extends StatelessWidget {
  final SongModel song;

  /// callback khi bấm play
  final VoidCallback? onPlay;

  /// callback khi bấm vào item
  final VoidCallback? onTap;

  /// callback khi chọn "Thêm vào playlist"
  final VoidCallback? onAddToPlaylist;

  const SongItem({
    super.key,
    required this.song,
    this.onPlay,
    this.onTap,
    this.onAddToPlaylist,
  });

  @override
  Widget build(BuildContext context) {
    final int? sid = song.songId; // id bài hát của bạn là songId

    return ValueListenableBuilder<Set<int>>(
      valueListenable: FavoriteApiService.instance.favoriteSongIds,
      builder: (context, favIds, _) {
        final bool isFav = (sid != null) && favIds.contains(sid);

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
              // ❤️ Nút yêu thích
              IconButton(
                icon: Icon(
                  isFav ? Icons.favorite : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: sid == null
                    ? null
                    : () async {
                  try {
                    await FavoriteApiService.instance.toggleFavorite(sid);
                  } catch (e) {
                    // báo lỗi gọn gàng
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Lỗi yêu thích: $e')),
                      );
                    }
                  }
                },
              ),

              // ▶️ Nút play
              IconButton(
                icon: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.green,
                  size: 28,
                ),
                onPressed: onPlay,
              ),

              // ⋮ Nút more -> mở bottom sheet
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showSongActionSheet(
                    context,
                    song: song,
                    isFavorite: isFav,
                    onToggleFavorite: sid == null
                        ? null
                        : () async {
                      try {
                        await FavoriteApiService.instance
                            .toggleFavorite(sid);
                      } catch (e) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi: $e')),
                          );
                        }
                      }
                    },
                    onAddToPlaylist: onAddToPlaylist,
                  );
                },
              ),
            ],
          ),

          // ===== TAP VÀO ITEM =====
          onTap: onTap,
        );
      },
    );
  }
}
