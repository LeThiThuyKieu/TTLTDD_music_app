import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../screens/home/music_player_screen.dart';

class SongItem extends StatelessWidget {
  final SongModel song;

  /// Callback khi bấm nút Play
  final VoidCallback? onPlay;

  /// Callback khi bấm vào toàn bộ item
  final VoidCallback? onTap;

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
    this.onYeuThich,
    this.onThemVaoPlaylist,
    this.onXemCaSi,
    this.onThamGiaAlbum,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          song.coverUrl ?? '',
          width: 50,
          height: 50,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Icon(Icons.music_note, size: 40),
        ),
      ),
      title: Text(
        song.title,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        song.artists?.map((e) => e.name).join(', ') ?? 'Ca sĩ không xác định',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // ==== Nút Play ====
          IconButton(
            icon: const Icon(
              Icons.play_circle_fill,
              color: Colors.green,
              size: 28,
            ),
            onPressed: onPlay ??
                () {
                  print('Play ${song.title}');
                  // TODO: Dev khác gán logic phát nhạc
                },
          ),

          // ==== Nút menu 3 chấm ====
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
                              print('Yêu thích ${song.title}');
                              // TODO: Dev khác gán logic yêu thích
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
                              print('Thêm ${song.title} vào playlist');
                              // TODO: Dev khác gán logic thêm playlist
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
                              print('Xem ca sĩ ${song.title}');
                              // TODO: Dev khác gán logic xem ca sĩ
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
                              print('Đi đến album ${song.title}');
                              // TODO: Dev khác gán logic đi đến album
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
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    const MusicPlayerScreen(), // màn hình trình phát đầy đủ
              ),
            );
          },
    );
  }
}
