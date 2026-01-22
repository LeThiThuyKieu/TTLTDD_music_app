import 'package:flutter/material.dart';

import '../../models/playlist_model.dart';
import '../../services/playlist_api_service.dart';
import '../../services/favorite_api_service.dart';

import 'playlist_detail_screen.dart';
import 'favorites_screen.dart';

class PlaylistListScreen extends StatefulWidget {
  const PlaylistListScreen({super.key});

  @override
  State<PlaylistListScreen> createState() => _PlaylistListScreenState();
}

class _PlaylistListScreenState extends State<PlaylistListScreen> {
  bool _loading = true;

  // lưu lỗi nếu gọi API thất bại
  String? _error;
// danh sách playlist
  List<PlaylistModel> _playlists = [];
  // key sắp xếp: recent | name
  String _sortKey = 'recent'; // recent | name

  @override
  void initState() {
    super.initState();
    _load();
    FavoriteApiService.instance.loadFavorites();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await PlaylistApiService.instance.getMyPlaylists();

      // loại bỏ playlist like trùng
      final filtered = list.where((p) => !_isLikesPlaylist(p.name)).toList();

      setState(() {
        _playlists = _applySort(filtered);
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

    if (_sortKey == 'name') {
      copied.sort((a, b) =>
          a.name.toLowerCase().compareTo(b.name.toLowerCase()));
    } else {
      copied.sort((a, b) {
        final ad = a.createdAt;
        final bd = b.createdAt;
        if (ad != null && bd != null) return bd.compareTo(ad);
        return b.playlistId.compareTo(a.playlistId);
      });
    }
    return copied;
  }

  Future<void> _pickSort() async {
    final v = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title:
            Text('Sort by', style: TextStyle(fontWeight: FontWeight.w800)),
          ),
          RadioListTile(
            value: 'recent',
            groupValue: _sortKey,
            title: const Text('Recently Added'),
            onChanged: (v) => Navigator.pop(context, v),
          ),
          RadioListTile(
            value: 'name',
            groupValue: _sortKey,
            title: const Text('Name (A–Z)'),
            onChanged: (v) => Navigator.pop(context, v),
          ),
        ],
      ),
    );

    if (v != null) {
      setState(() {
        _sortKey = v;
        _playlists = _applySort(_playlists);
      });
    }
  }

  // ============================
  // ADD NEW PLAYLIST
  // ============================
  Future<void> _openCreatePlaylist() async {
    final ok = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => const _CreatePlaylistSheet(),
    );

    if (ok == true) _load();
  }

  // ============================
  // YOUR LIKES TILE
  // ============================
  Widget _buildYourLikes() {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: FavoriteApiService.instance.favoriteSongIds,
      builder: (_, favIds, __) {
        return _RowTile(
          leading: const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF22C55E),
            child: Icon(Icons.favorite, color: Colors.white),
          ),
          title: 'Your Likes',
          subtitle: '${favIds.length} songs',
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const FavoritesScreen()),
            );
          },
        );
      },
    );
  }

  static bool _isLikesPlaylist(String name) {
    final n = name.toLowerCase();
    return n.contains('like') ||
        n.contains('favorite') ||
        n.contains('yêu thích');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon:
          const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Playlists',
          style: TextStyle(fontWeight: FontWeight.w900, color: Colors.black),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {},
          ),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Lỗi: $_error'))
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Row(
              children: [
                const Text('Sort by',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 12),
                InkWell(
                  onTap: _pickSort,
                  child: Row(
                    children: [
                      const Icon(Icons.swap_vert,
                          size: 18, color: Color(0xFF22C55E)),
                      const SizedBox(width: 6),
                      Text(
                        _sortKey == 'name'
                            ? 'Name (A–Z)'
                            : 'Recently Added',
                        style: const TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),

            // ADD NEW PLAYLIST
            _RowTile(
              leading: const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFF22C55E),
                child: Icon(Icons.add, color: Colors.white),
              ),
              title: 'Add New Playlist',
              onTap: _openCreatePlaylist,
            ),

            const SizedBox(height: 6),

            // YOUR LIKES
            _buildYourLikes(),

            const SizedBox(height: 6),

            ..._playlists.map((p) => _RowTile(
              leading: const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFFEFFDF5),
                child: Padding(
                  padding: EdgeInsets.all(6),
                  child: Image(
                    image: AssetImage('assets/images/default_album.png'),
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              title: p.name,
              subtitle: '${p.songs?.length ?? 0} songs',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => PlaylistDetailScreen(
                        playlistId: p.playlistId),
                  ),
                );
              },
            )),
          ],
        ),
      ),
    );
  }
}

// ==========================
// CREATE PLAYLIST SHEET
// ==========================
class _CreatePlaylistSheet extends StatefulWidget {
  const _CreatePlaylistSheet();

  @override
  State<_CreatePlaylistSheet> createState() => _CreatePlaylistSheetState();
}

class _CreatePlaylistSheetState extends State<_CreatePlaylistSheet> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  bool _public = true;
  bool _loading = false;

  Future<void> _create() async {
    if (_nameCtrl.text.trim().isEmpty) return;

    setState(() => _loading = true);

    try {
      await PlaylistApiService.instance.createPlaylist(
        name: _nameCtrl.text.trim(),
        isPublic: _public,
      );
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('New Playlist',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 12),

          TextField(
            controller: _nameCtrl,
            decoration: const InputDecoration(hintText: 'Playlist name'),
          ),
          const SizedBox(height: 10),

          TextField(
            controller: _descCtrl,
            decoration: const InputDecoration(hintText: 'Description'),
          ),
          const SizedBox(height: 10),

          DropdownButtonFormField<bool>(
            value: _public,
            items: const [
              DropdownMenuItem(value: true, child: Text('Public')),
              DropdownMenuItem(value: false, child: Text('Private')),
            ],
            onChanged: (v) => setState(() => _public = v ?? true),
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _loading ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _loading ? null : _create,
                  child: _loading
                      ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : const Text('Create'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================
// ROW TILE
// ==========================
class _RowTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;

  const _RowTile({
    required this.leading,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          children: [
            leading,
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style:
                      const TextStyle(fontWeight: FontWeight.w800)),
                  if (subtitle != null)
                    Text(subtitle!,
                        style:
                        const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            const Icon(Icons.more_vert, color: Colors.black54),
          ],
        ),
      ),
    );
  }
}
