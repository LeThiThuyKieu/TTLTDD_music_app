import 'package:flutter/material.dart';
import '../../models/playlist_model.dart';
import '../../services/playlist_api_service.dart';
import '../../services/favorite_api_service.dart';
import 'favorites_screen.dart';
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
    FavoriteApiService.instance.loadFavorites(); // ✅ load likes
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final list = await PlaylistApiService.instance.getMyPlaylists();

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

    if (_sortKey == "name") {
      copied.sort((a, b) => a.name.toLowerCase().compareTo(b.name.toLowerCase()));
      return copied;
    }

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
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const ListTile(
              title: Text("Sort by", style: TextStyle(fontWeight: FontWeight.w800)),
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

  // =========================
  // ✅ YOUR LIKES (FIX HOÀN CHỈNH)
  // =========================
  Widget _buildYourLikesTile() {
    return ValueListenableBuilder<Set<int>>(
      valueListenable: FavoriteApiService.instance.favoriteSongIds,
      builder: (context, favIds, _) {
        return _RowTile(
          leading: const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFF22C55E),
            child: Icon(Icons.favorite, color: Colors.white),
          ),
          title: "Your Likes",
          subtitle: "${favIds.length} songs",
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const FavoritesScreen(),
              ),
            );
          },
          trailing: IconButton(
            icon: const Icon(Icons.more_vert, color: Colors.black54),
            onPressed: () {},
          ),
        );
      },
    );
  }

  static bool _isLikesPlaylist(String name) {
    final n = name.toLowerCase();
    return n.contains("your likes") ||
        n.contains("like") ||
        n.contains("favorite") ||
        n.contains("yêu thích");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 18, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Playlists",
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w800),
        ),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text("Lỗi: $_error"))
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            Row(
              children: [
                const Text("Sort by", style: TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(width: 16),
                InkWell(
                  onTap: _pickSort,
                  child: Row(
                    children: [
                      const Icon(Icons.swap_vert, size: 18, color: Color(0xFF22C55E)),
                      const SizedBox(width: 6),
                      Text(
                        _sortKey == "name" ? "Name (A-Z)" : "Recently Added",
                        style: const TextStyle(
                          color: Color(0xFF22C55E),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const Icon(Icons.keyboard_arrow_down,
                          size: 18, color: Color(0xFF22C55E)),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(),

            // Add new playlist
            _RowTile(
              leading: const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFF22C55E),
                child: Icon(Icons.add, color: Colors.white),
              ),
              title: "Add New Playlist",
              subtitle: null,
              onTap: () {},
              trailing: const SizedBox(width: 24),
            ),

            const SizedBox(height: 6),

            // ✅ YOUR LIKES
            _buildYourLikesTile(),

            const SizedBox(height: 6),

            ..._playlists.map((p) {
              return _RowTile(
                leading: const CircleAvatar(
                  radius: 22,
                  backgroundColor: Color(0xFFEFFDF5),
                  child: Icon(Icons.queue_music, color: Color(0xFF22C55E)),
                ),
                title: p.name,
                subtitle: "${p.songs?.length ?? 0} songs",
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PlaylistDetailScreen(
                        playlistId: p.playlistId,
                      ),
                    ),
                  );
                },
                trailing: const Icon(Icons.more_vert),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// =========================
// UI Row Tile
// =========================
class _RowTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Widget trailing;

  const _RowTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.trailing,
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
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w800)),
                  if (subtitle != null)
                    Text(subtitle!, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            trailing,
          ],
        ),
      ),
    );
  }
}
