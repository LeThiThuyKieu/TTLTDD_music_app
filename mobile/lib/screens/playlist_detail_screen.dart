import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/playlist_model.dart';
import '../../services/playlist_api_service.dart';
import '../../services/audio_player_service.dart';
import '../../widgets/song_item.dart';
import '../../widgets/add_to_playlist_sheet.dart';
import '../../widgets/scaffold_with_mini_player.dart';

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

      debugPrint("DETAIL OK id=${widget.playlistId} name=${p.name} songs=${p.songs?.length}");

      setState(() {
        _playlist = p;
        _loading = false;
      });
    } catch (e) {
      debugPrint("DETAIL ERROR id=${widget.playlistId} err=$e");
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

  String _artistLine(dynamic song) {
    try {
      final artists = song?.artists;
      if (artists is List && artists.isNotEmpty) {
        final names = artists.map((a) {
          final n = (a?.name ?? a?.artistName ?? a?.fullName ?? "").toString().trim();
          return n;
        }).where((s) => s.isNotEmpty).toList();

        if (names.isNotEmpty) return names.join(", ");
      }
    } catch (_) {}
    return "Unknown artist";
  }

  String _songsCountLabel(List<dynamic>? songs) {
    if (songs == null) return "— songs";
    return "${songs.length} songs";
  }

  Future<void> _openSongMenu(dynamic song) async {
    final title = (song?.title ?? "Unknown title").toString();
    final sid = song?.songId is int ? song.songId as int : null;

    final action = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
              subtitle: Text(_artistLine(song)),
            ),
            const Divider(height: 1),

            // ✅ Like chuyển vào menu 3 chấm (theo yêu cầu)
            ListTile(
              leading: const Icon(Icons.favorite_border),
              title: const Text("Like"),
              onTap: () => Navigator.pop(context, "like"),
            ),
            ListTile(
              leading: const Icon(Icons.download_outlined),
              title: const Text("Download"),
              onTap: () => Navigator.pop(context, "download"),
            ),
            ListTile(
              leading: const Icon(Icons.playlist_add),
              title: const Text("Add to playlist"),
              onTap: () => Navigator.pop(context, "add_to_playlist"),
            ),
            ListTile(
              leading: const Icon(Icons.remove_circle_outline, color: Colors.red),
              title: const Text("Remove from this playlist", style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context, "remove"),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    if (action == "like") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("TODO: Like/Unlike bài hát")),
      );
      return;
    }

    if (action == "download") {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("TODO: Download bài hát")),
      );
      return;
    }

    if (action == "add_to_playlist") {
      showAddToPlaylistSheet(context, song);
      return;
    }

    if (action == "remove") {
      if (sid == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Không tìm thấy songId để xóa")),
        );
        return;
      }

      final ok = await showDialog<bool>(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text("Xóa khỏi playlist?"),
          content: Text('Bỏ "$title" khỏi playlist này?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
            ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Xóa")),
          ],
        ),
      );

      if (ok == true) {
        await _removeSong(sid);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _playlist;
    final songs = p?.songs;
    final audioPlayer = context.watch<AudioPlayerService>();
    final hasSong = audioPlayer.currentSong != null;

    return ScaffoldWithMiniPlayer(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          p?.name ?? "Playlist",
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w900),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {},
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Lỗi: $_error"))
          : p == null
          ? Center(child: Text("Không tìm thấy playlist id=${widget.playlistId}"))
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: EdgeInsets.fromLTRB(16, 14, 16, hasSong ? 80 : 16),
          children: [
            // ===== HEADER giống mẫu =====
            _PlaylistHeader(
              title: p.name,
              subtitle: _songsCountLabel(songs?.cast<dynamic>()),
              onLike: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("TODO: Like playlist")),
                );
              },
              onDownload: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("TODO: Download playlist")),
                );
              },
              onShare: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("TODO: Share playlist")),
                );
              },
              onMore: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("TODO: More actions")),
                );
              },
              onShuffle: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("TODO: Shuffle")),
                );
              },
              onPlay: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("TODO: Play")),
                );
              },
            ),
            const SizedBox(height: 14),

            // ===== EMPTY STATE =====
            if (songs == null)
              _EmptyCard(
                title: "API chưa trả danh sách bài hát",
                subtitle:
                "Endpoint GET /playlists/:id cần trả về { ...playlist, songs: [...] }",
                onReload: _load,
              )
            else if (songs.isEmpty)
              _EmptyCard(
                title: "Playlist chưa có bài hát",
                subtitle: "Hãy thêm bài để xem danh sách.",
                onReload: _load,
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

                    // ✅ row bài hát: KHÔNG có tim, tim nằm trong menu 3 chấm
                    child: _SongTile(
                      title: song.title,
                      subtitle: _artistLine(song),
                      coverUrl: song.coverUrl,
                      onPlay: () => debugPrint("Play: ${song.title}"),
                      onTap: () => debugPrint("Open player: ${song.title}"),
                      onMore: () => _openSongMenu(song),
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

class _PlaylistHeader extends StatelessWidget {
  final String title;
  final String subtitle;

  final VoidCallback onLike;
  final VoidCallback onDownload;
  final VoidCallback onShare;
  final VoidCallback onMore;

  final VoidCallback onShuffle;
  final VoidCallback onPlay;

  const _PlaylistHeader({
    required this.title,
    required this.subtitle,
    required this.onLike,
    required this.onDownload,
    required this.onShare,
    required this.onMore,
    required this.onShuffle,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          Row(
            children: [
              // thumb trái
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 56,
                  height: 56,
                  color: const Color(0xFFF2F2F2),
                  child: const Icon(Icons.queue_music, color: Colors.black38),
                ),
              ),
              const SizedBox(width: 12),

              // title + subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Playlist · $subtitle",
                      style: const TextStyle(color: Colors.black54, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ✅ hàng icon tim / download / share / more ở TRÊN (đúng yêu cầu)
          Row(
            children: [
              _CircleIconButton(icon: Icons.favorite_border, onTap: onLike),
              const SizedBox(width: 10),
              _CircleIconButton(icon: Icons.download_outlined, onTap: onDownload),
              const SizedBox(width: 10),
              _CircleIconButton(icon: Icons.share_outlined, onTap: onShare),
              const SizedBox(width: 10),
              _CircleIconButton(icon: Icons.more_horiz, onTap: onMore),
              const Spacer(),
            ],
          ),

          const SizedBox(height: 10),

          // Shuffle / Play pill
          Row(
            children: [
              Expanded(
                child: _PillButton(
                  text: "Shuffle",
                  filled: true,
                  icon: Icons.shuffle,
                  onTap: onShuffle,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _PillButton(
                  text: "Play",
                  filled: false,
                  icon: Icons.play_arrow,
                  onTap: onPlay,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SongTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? coverUrl;
  final VoidCallback onPlay;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const _SongTile({
    required this.title,
    required this.subtitle,
    required this.coverUrl,
    required this.onPlay,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              _Cover(url: coverUrl),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.black54, fontSize: 12),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),

              // nút play nhỏ
              InkWell(
                onTap: onPlay,
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 30,
                  height: 30,
                  decoration: BoxDecoration(
                    color: const Color(0xFFEFFDF5),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.play_arrow, size: 18, color: Color(0xFF22C55E)),
                ),
              ),

              // ✅ 3 chấm (Like chuyển vào đây)
              IconButton(
                onPressed: onMore,
                icon: const Icon(Icons.more_vert, color: Colors.black54),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Cover extends StatelessWidget {
  final String? url;
  const _Cover({required this.url});

  @override
  Widget build(BuildContext context) {
    final u = url?.trim();
    if (u != null && u.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          u,
          width: 46,
          height: 46,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Icon(Icons.music_note, color: Colors.black38, size: 22),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: const Color(0xFFF3F4F6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(icon, color: Colors.black54, size: 18),
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  final String text;
  final bool filled;
  final IconData icon;
  final VoidCallback onTap;

  const _PillButton({
    required this.text,
    required this.filled,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bg = filled ? const Color(0xFF22C55E) : Colors.white;
    final fg = filled ? Colors.white : const Color(0xFF22C55E);
    final border = filled ? Colors.transparent : const Color(0xFF22C55E);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: border),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: fg, size: 18),
            const SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(color: fg, fontWeight: FontWeight.w900),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final VoidCallback onReload;

  const _EmptyCard({
    required this.title,
    required this.subtitle,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.w900)),
          const SizedBox(height: 8),
          Text(subtitle, textAlign: TextAlign.center, style: const TextStyle(color: Colors.black54)),
          const SizedBox(height: 12),
          OutlinedButton(onPressed: onReload, child: const Text("Reload")),
        ],
      ),
    );
  }
}
