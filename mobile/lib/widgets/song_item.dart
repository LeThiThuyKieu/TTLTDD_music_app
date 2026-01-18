import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../services/favorite_api_service.dart';
import '../services/audio_player_service.dart';
import '../screens/home/music_player_screen.dart';

class SongItem extends StatelessWidget {
  final SongModel song;

  /// Callback khi bấm nút Play
  final VoidCallback? onPlay;

  /// Callback khi bấm vào toàn bộ item
  final VoidCallback? onTap;

  /// callback khi chọn "Thêm vào playlist"
  final VoidCallback? onAddToPlaylist;

  /// Callback khi bấm "Xem ca sĩ"
  final VoidCallback? onXemCaSi;

  /// Callback khi bấm "Đi đến album"
  final VoidCallback? onThamGiaAlbum;

  const SongItem({
    super.key,
    required this.song,
    this.onPlay,
    this.onTap,
    this.onAddToPlaylist,
    this.onXemCaSi,
    this.onThamGiaAlbum,
  });

  @override
  Widget build(BuildContext context) {
    final int? sid = song.songId;

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
            song.artists.map((e) => e.name).join(', '),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // ===== NÚT BÊN PHẢI =====
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ▶️ Play
              IconButton(
                icon: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.green,
                  size: 28,
                ),
                onPressed: onPlay ??
                    () {
                      context
                          .read<AudioPlayerService>()
                          .playSong(song);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const MusicPlayerScreen(),
                        ),
                      );
                    },
              ),

              // ❤️ Favorite
              IconButton(
                icon: Icon(
                  isFav
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFav ? Colors.red : null,
                ),
                onPressed: sid == null
                    ? null
                    : () async {
                        await FavoriteApiService.instance
                            .toggleFavorite(sid);
                      },
              ),

              // ⋮ Menu
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    showDragHandle: true,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.vertical(
                        top: Radius.circular(16),
                      ),
                    ),
                    builder: (_) => SafeArea(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Yêu thích
                          ListTile(
                            leading: Icon(
                              isFav
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color:
                                  isFav ? Colors.red : null,
                            ),
                            title: Text(
                              isFav
                                  ? 'Bỏ yêu thích'
                                  : 'Thêm vào yêu thích',
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                              if (sid != null) {
                                await FavoriteApiService
                                    .instance
                                    .toggleFavorite(sid);
                              }
                            },
                          ),

                          // Thêm vào playlist
                          ListTile(
                            leading:
                                const Icon(Icons.playlist_add),
                            title: const Text(
                                'Thêm vào playlist'),
                            onTap: () {
                              Navigator.pop(context);
                              onAddToPlaylist?.call();
                            },
                          ),

                          // Xem ca sĩ
                          ListTile(
                            leading:
                                const Icon(Icons.person),
                            title:
                                const Text('Xem ca sĩ'),
                            onTap: () {
                              Navigator.pop(context);
                              onXemCaSi?.call();
                            },
                          ),

                          // Đi đến album
                          ListTile(
                            leading:
                                const Icon(Icons.album),
                            title:
                                const Text('Đi đến album'),
                            onTap: () {
                              Navigator.pop(context);
                              onThamGiaAlbum?.call();
                            },
                          ),

                          const SizedBox(height: 8),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // ===== TAP TOÀN ITEM =====
          onTap: onTap ??
              () {
                context
                    .read<AudioPlayerService>()
                    .playSong(song);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const MusicPlayerScreen(),
                  ),
                );
              },
        );
      },
    );
  }
}
