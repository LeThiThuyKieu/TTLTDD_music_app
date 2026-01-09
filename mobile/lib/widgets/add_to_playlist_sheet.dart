import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/playlist_api_service.dart';

Future<void> showAddToPlaylistSheet(BuildContext context, SongModel song) async {
  final sid = song.songId;
  if (sid == null) return;

  await showModalBottomSheet(
    context: context,
    showDragHandle: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (_) => _AddToPlaylistBody(songId: sid, songTitle: song.title),
  );
}

class _AddToPlaylistBody extends StatefulWidget {
  final int songId;
  final String songTitle;
  const _AddToPlaylistBody({required this.songId, required this.songTitle});

  @override
  State<_AddToPlaylistBody> createState() => _AddToPlaylistBodyState();
}

class _AddToPlaylistBodyState extends State<_AddToPlaylistBody> {
  bool _loading = true;
  String? _error;
  dynamic _playlists;

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
      final list = await PlaylistApiService.instance.getMyPlaylists();
      setState(() {
        _playlists = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  Future<void> _add(int playlistId) async {
    await PlaylistApiService.instance.addSongToPlaylist(playlistId, widget.songId);
    if (mounted) Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Đã thêm "${widget.songTitle}" vào playlist')),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) return const Padding(
      padding: EdgeInsets.all(24),
      child: Center(child: CircularProgressIndicator()),
    );

    if (_error != null) return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(child: Text('Lỗi: $_error')),
    );

    final list = _playlists as List;
    if (list.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: Text('Bạn chưa có playlist nào')),
      );
    }

    return SafeArea(
      child: ListView.separated(
        shrinkWrap: true,
        itemCount: list.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final p = list[index];
          final pid = p.playlistId as int?;
          return ListTile(
            leading: const Icon(Icons.queue_music),
            title: Text(p.name),
            onTap: pid == null ? null : () => _add(pid),
          );
        },
      ),
    );
  }
}
