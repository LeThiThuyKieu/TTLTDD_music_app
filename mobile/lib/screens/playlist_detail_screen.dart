import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../services/playlist_api_service.dart';
import '../widgets/song_item.dart';
import '../widgets/add_to_playlist_sheet.dart';

class PlaylistDetailScreen extends StatefulWidget {
  final int playlistId;
  const PlaylistDetailScreen({super.key, required this.playlistId});

  @override
  State<PlaylistDetailScreen> createState() => _PlaylistDetailScreenState();
}

class _PlaylistDetailScreenState extends State<PlaylistDetailScreen> {
  bool _loading = true;
  String? _error;
  PlaylistModel? _playlist;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final p = await PlaylistApiService.instance.getPlaylistDetail(widget.playlistId);

      // Debug chắc chắn có songs
      debugPrint("DETAIL playlistId=${widget.playlistId} name=${p?.name} songs=${p?.songs?.length}");

      setState(() {
        _playlist = p;
        _loading = false;
      });
    } catch (e) {
      debugPrint("DETAIL ERROR playlistId=${widget.playlistId} error=$e");
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _removeSong(int songId) async {
    await PlaylistApiService.instance.removeSongFromPlaylist(widget.playlistId, songId);

    await _load();

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Đã xóa bài khỏi playlist')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _playlist;
    final songs = p?.songs ?? const [];

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(p?.name ?? "Playlist Detail"),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? _ErrorView(
        error: _error!,
        onRetry: _load,
        playlistId: widget.playlistId,
      )
          : p == null
          ? _EmptyView(
        title: "Không tìm thấy playlist",
        subtitle:
        "playlistId=${widget.playlistId}\nKiểm tra API GET /api/playlists/${widget.playlistId}",
        actionText: "Reload",
        onAction: _load,
      )
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            _HeaderCard(
              name: p.name,
              countText: "${songs.length} songs",
              onAddSongs: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("TODO: mở màn chọn bài để thêm vào playlist")),
                );
              },
            ),
            const SizedBox(height: 12),

            if (songs.isEmpty)
              _EmptyView(
                title: "Playlist chưa có bài hát",
                subtitle: "Bạn hãy thêm bài hát vào playlist để xem danh sách ở đây.",
                actionText: "Reload",
                onAction: _load,
              )
            else
              ...songs.map((song) {
                final sid = song.songId;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Dismissible(
                    key: ValueKey(sid ?? "${song.title}-${song.fileUrl}"),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Icon(Icons.delete, color: Colors.white),
                    ),
                    confirmDismiss: (_) async {
                      return await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text("Xóa khỏi playlist?"),
                          content: Text('Bỏ "${song.title}" khỏi playlist này?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text("Hủy"),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text("Xóa"),
                            ),
                          ],
                        ),
                      );
                    },
                    onDismissed: (_) async {
                      if (sid != null) await _removeSong(sid);
                    },
                    child: Card(
                      elevation: 0,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: SongItem(
                        song: song,
                        onPlay: () => debugPrint("Play: ${song.title}"),
                        onTap: () => debugPrint("Open player: ${song.title}"),
                        onAddToPlaylist: () => showAddToPlaylistSheet(context, song),
                      ),
                    ),
                  ),
                );
              }).toList(),
          ],
        ),
      ),
    );
  }
}

class _HeaderCard extends StatelessWidget {
  final String name;
  final String countText;
  final VoidCallback onAddSongs;

  const _HeaderCard({
    required this.name,
    required this.countText,
    required this.onAddSongs,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 26,
            backgroundColor: Color(0xFFEFFDF5),
            child: Icon(Icons.queue_music, color: Color(0xFF22C55E)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(countText, style: const TextStyle(color: Colors.black54)),
              ],
            ),
          ),
          const SizedBox(width: 10),
          ElevatedButton.icon(
            onPressed: onAddSongs,
            icon: const Icon(Icons.add),
            label: const Text("Add"),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final String title;
  final String subtitle;
  final String actionText;
  final VoidCallback onAction;

  const _EmptyView({
    required this.title,
    required this.subtitle,
    required this.actionText,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onAction, child: Text(actionText)),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  final int playlistId;

  const _ErrorView({
    required this.error,
    required this.onRetry,
    required this.playlistId,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 42, color: Colors.red),
            const SizedBox(height: 8),
            const Text("Không load được playlist", style: TextStyle(fontWeight: FontWeight.w800)),
            const SizedBox(height: 8),
            Text(
              "Lỗi: $error\n\nKiểm tra:\n- Token còn hạn\n- GET /api/playlists/$playlistId\n- User có quyền truy cập playlist",
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text("Retry")),
          ],
        ),
      ),
    );

  }
}
