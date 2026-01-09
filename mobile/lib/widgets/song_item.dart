import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/favorite_api_service.dart';
import '../screens/home/music_player_screen.dart';

class SongItem extends StatelessWidget {
  final SongModel song;

  /// Callback khi bấm nút Play
  final VoidCallback? onPlay;

  /// Callback khi bấm vào toàn bộ item
  final VoidCallback? onTap;

  /// callback khi chọn "Thêm vào playlist"
  final VoidCallback? onAddToPlaylist;

  /// Callback khi bấm "Yêu thích" trong menu 3 chấm
  final VoidCallback? onYeuThich;

  /// Callback khi bấm "Thêm vào playlist" trong menu 3 chấm
  final VoidCallback? onThemVaoPlaylist;

  /// Callback khi bấm "Xem ca sĩ" trong menu 3 chấm
  final VoidCallback? onXemCaSi;

  /// Callback khi bấm "Đi đến album" trong menu 3 chấm
  final VoidCallback? onThamGiaAlbum;

  const SongItem({
    super.key,
    required this.song,
    this.onPlay,
    this.onTap,
    this.onAddToPlaylist,
    this.onYeuThich,
    this.onThemVaoPlaylist,
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
            song.artists?.map((e) => e.name).join(', ') ?? 'Unknown artist',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),

          // ===== NÚT BÊN PHẢI =====
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ▶️ Nút play
              IconButton(
                icon: const Icon(
                  Icons.play_circle_fill,
                  color: Colors.green,
                  size: 28,
                ),
                onPressed: onPlay,
              ),

              // ⋮ Nút menu 3 chấm
              IconButton(
                icon: const Icon(Icons.more_vert),
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (_) => Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Menu: Yêu thích
                        ListTile(
                          leading: const Icon(Icons.favorite_border),
                          title: const Text('Yêu thích'),
                          onTap: () {
                            Navigator.pop(context);
                            (onYeuThich ??
                                    () {
                                  debugPrint('Yêu thích ${song.title}');
                                })();
                          },
                        ),

                        // Menu: Thêm vào playlist
                        ListTile(
                          leading: const Icon(Icons.playlist_add),
                          title: const Text('Thêm vào playlist'),
                          onTap: () {
                            Navigator.pop(context);
                            (onThemVaoPlaylist ??
                                    () {
                                  debugPrint('Thêm ${song.title} vào playlist');
                                })();
                          },
                        ),

                        // Menu: Xem ca sĩ
                        ListTile(
                          leading: const Icon(Icons.person),
                          title: const Text('Xem ca sĩ'),
                          onTap: () {
                            Navigator.pop(context);
                            (onXemCaSi ??
                                    () {
                                  debugPrint('Xem ca sĩ của ${song.title}');
                                })();
                          },
                        ),

                        // Menu: Đi đến album
                        ListTile(
                          leading: const Icon(Icons.album),
                          title: const Text('Đi đến album'),
                          onTap: () {
                            Navigator.pop(context);
                            (onThamGiaAlbum ??
                                    () {
                                  debugPrint('Đi đến album của ${song.title}');
                                })();
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),

          // Khi bấm vào toàn bộ item
          onTap: onTap ??
                  () {
                debugPrint('Bấm vào item ${song.title}');
              },
        );
      },
    );
  }
}
