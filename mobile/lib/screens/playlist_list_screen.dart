import 'package:flutter/material.dart';
import '../models/playlist_model.dart';
import '../services/playlist_api_service.dart';
import 'playlist_detail_screen.dart';

class PlaylistListScreen extends StatefulWidget {
  const PlaylistListScreen({super.key});

  @override
  State<PlaylistListScreen> createState() => _PlaylistListScreenState();
}

class _PlaylistListScreenState extends State<PlaylistListScreen> {
  bool _loading = true;
  String? _error;
  List<PlaylistModel> _playlists = [];

  String _sortKey = "recent"; // recent | name

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
        _playlists = _applySort(list);
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  List<PlaylistModel> _applySort(List<PlaylistModel> list) {
    final copied = [...list];

    if (_sortKey == "name") {
      copied.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return copied;
    }

    // recent: ưu tiên createdAt mới hơn, fallback playlistId lớn hơn
    copied.sort((a, b) {
      final ad = a.createdAt;
      final bd = b.createdAt;
      if (ad != null && bd != null) return bd.compareTo(ad);

      return b.playlistId.compareTo(a.playlistId);
    });

    return copied;
  }

  Future<void> _pickSort() async {
    final value = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text("Sort by", style: TextStyle(fontWeight: FontWeight.w700)),
            ),
            RadioListTile<String>(
              value: "recent",
              groupValue: _sortKey,
              title: const Text("Recently Added"),
              onChanged: (v) => Navigator.pop(context, v),
            ),
            RadioListTile<String>(
              value: "name",
              groupValue: _sortKey,
              title: const Text("Name (A-Z)"),
              onChanged: (v) => Navigator.pop(context, v),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (value != null && mounted) {
      setState(() {
        _sortKey = value;
        _playlists = _applySort(_playlists);
      });
    }
  }

  Future<void> _createPlaylistDialog() async {
    final controller = TextEditingController();

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Add New Playlist'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: 'Playlist name'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Create')),
        ],
      ),
    );

    final name = controller.text.trim();
    if (ok == true && name.isNotEmpty) {
      await PlaylistApiService.instance.createPlaylist(name: name);
      await _load();
    }
  }

  Future<void> _openPlaylistMenu(PlaylistModel p) async {
    final pid = p.playlistId;

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
              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
              subtitle: Text(_songsCountLabel(p)),
            ),
            ListTile(
              leading: const Icon(Icons.edit_outlined),
              title: const Text("Rename"),
              onTap: () => Navigator.pop(context, "rename"),
            ),
            ListTile(
              leading: const Icon(Icons.delete_outline, color: Colors.red),
              title: const Text("Delete", style: TextStyle(color: Colors.red)),
              onTap: () => Navigator.pop(context, "delete"),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );

    if (!mounted || action == null) return;

    if (action == "rename") {
      await _renamePlaylist(pid, p.name);
    } else if (action == "delete") {
      await _deletePlaylist(pid);
    }
  }

  Future<void> _renamePlaylist(int playlistId, String oldName) async {
    final controller = TextEditingController(text: oldName);

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Rename playlist"),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: "New name"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text("Save")),
        ],
      ),
    );

    final newName = controller.text.trim();
    if (ok == true && newName.isNotEmpty && newName != oldName) {
      await PlaylistApiService.instance.updatePlaylist(playlistId, name: newName);
      await _load();
    }
  }

  Future<void> _deletePlaylist(int playlistId) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete playlist?"),
        content: const Text("This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Cancel")),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (ok == true) {
      await PlaylistApiService.instance.deletePlaylist(playlistId);
      await _load();
    }
  }

  Future<void> _openDetail(PlaylistModel p) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PlaylistDetailScreen(
          playlistId: p.playlistId,
        ),
      ),
    );

    await _load();
  }

  static String _songsCountLabel(PlaylistModel p) {
    // /playlists/my thường không trả songs => null
    if (p.songs == null) return "— songs";
    return "${p.songs!.length} songs";
  }

  static bool _isLikesPlaylist(String name) {
    final n = name.toLowerCase();
    return n.contains("like") || n.contains("favorite") || n.contains("yêu thích");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Playlists",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w700),
        ),
        iconTheme: const IconThemeData(color: Colors.black54),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {
              // TODO: Search playlists
            },
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Lỗi: $_error"))
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          children: [
            Row(
              children: [
                const Text("Sort by", style: TextStyle(fontWeight: FontWeight.w600)),
                const SizedBox(width: 12),
                TextButton.icon(
                  onPressed: _pickSort,
                  icon: const Icon(Icons.swap_vert, size: 18, color: Color(0xFF22C55E)),
                  label: Text(
                    _sortKey == "name" ? "Name (A-Z)" : "Recently Added",
                    style: const TextStyle(
                      color: Color(0xFF22C55E),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Add new playlist
            InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: _createPlaylistDialog,
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Color(0xFFEFFDF5),
                      child: Icon(Icons.add, color: Color(0xFF22C55E)),
                    ),
                    const SizedBox(width: 12),
                    const Text("Add New Playlist", style: TextStyle(fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 12),

            ..._playlists.map(
                  (p) => _PlaylistRow(
                playlist: p,
                subtitle: _songsCountLabel(p),
                isLikes: _isLikesPlaylist(p.name),
                onTap: () => _openDetail(p),
                onMore: () => _openPlaylistMenu(p),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaylistRow extends StatelessWidget {
  final PlaylistModel playlist;
  final String subtitle;
  final bool isLikes;
  final VoidCallback onTap;
  final VoidCallback onMore;

  const _PlaylistRow({
    required this.playlist,
    required this.subtitle,
    required this.isLikes,
    required this.onTap,
    required this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        onTap: onTap,
        leading: CircleAvatar(
          radius: 22,
          backgroundColor: const Color(0xFFEFFDF5),
          child: Icon(
            isLikes ? Icons.favorite : Icons.queue_music,
            color: const Color(0xFF22C55E),
          ),
        ),
        title: Text(
          playlist.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: Text(subtitle),
        trailing: IconButton(
          icon: const Icon(Icons.more_vert),
          onPressed: onMore,
        ),
      ),
    );
  }
}
