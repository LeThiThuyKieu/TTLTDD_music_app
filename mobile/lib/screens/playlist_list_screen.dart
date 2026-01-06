import 'package:flutter/material.dart';
import '../../models/playlist_model.dart';
import '../../services/playlist_api_service.dart';
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

      // ✅ tránh trùng với tile "Your Likes" cố định
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

  // =========================
  // ✅ New Playlist BottomSheet (giống hình mẫu)
  // =========================
  Future<void> _createPlaylistDialog() async {
    final nameCtrl = TextEditingController();
    bool isPublic = true;

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 8,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(height: 4),
                  const Text(
                    "New Playlist",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 16),

                  _sheetTextField(
                    controller: nameCtrl,
                    hint: "Most Popular Songs",
                  ),
                  const SizedBox(height: 10),

                  // giống UI mẫu, để disabled demo
                  _sheetTextField(
                    controller: TextEditingController(),
                    hint: "Most Popular Songs Latest Releases and Updates",
                    enabled: false,
                  ),
                  const SizedBox(height: 14),

                  // Public/Private dropdown
                  InkWell(
                    onTap: () async {
                      final value = await showModalBottomSheet<bool>(
                        context: ctx,
                        showDragHandle: true,
                        backgroundColor: Colors.white,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (_) => SafeArea(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              RadioListTile<bool>(
                                value: true,
                                groupValue: isPublic,
                                title: const Text("Public"),
                                onChanged: (v) => Navigator.pop(ctx, v),
                              ),
                              RadioListTile<bool>(
                                value: false,
                                groupValue: isPublic,
                                title: const Text("Private"),
                                onChanged: (v) => Navigator.pop(ctx, v),
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );

                      if (value != null) {
                        setModalState(() => isPublic = value);
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF7F7F7),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE7E7E7)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.public, size: 18, color: Colors.black54),
                          const SizedBox(width: 10),
                          Text(
                            isPublic ? "Public" : "Private",
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                          const Spacer(),
                          const Icon(Icons.keyboard_arrow_down, color: Colors.black45),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 18),

                  Row(
                    children: [
                      Expanded(
                        child: _sheetButton(
                          label: "Cancel",
                          filled: false,
                          onTap: () => Navigator.pop(ctx, false),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _sheetButton(
                          label: "Create",
                          filled: true,
                          onTap: () async {
                            final name = nameCtrl.text.trim();
                            if (name.isEmpty) return;

                            await PlaylistApiService.instance.createPlaylist(
                              name: name,
                              isPublic: isPublic ? 1 : 0,
                            );

                            if (ctx.mounted) Navigator.pop(ctx, true);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );

    if (created == true && mounted) {
      await _load();
    }
  }

  // =========================
  // ✅ Your Likes tile
  // =========================
  int _likesSongsCount() {
    // /playlists/my không trả songs -> tạm 0.
    // Sau này có API favorites/count thì thay ở đây.
    return 0;
  }

  Widget _buildYourLikesTile() {
    final count = _likesSongsCount();

    return _RowTile(
      leading: const CircleAvatar(
        radius: 22,
        backgroundColor: Color(0xFF22C55E),
        child: Icon(Icons.favorite, color: Colors.white),
      ),
      title: "Your Likes",
      subtitle: "$count songs",
      onTap: () {
        // TODO: điều hướng sang Favorites screen nếu bạn có
      },
      trailing: IconButton(
        icon: const Icon(Icons.more_vert, color: Colors.black54),
        onPressed: () {},
      ),
    );
  }

  Future<void> _openPlaylistMenu(PlaylistModel p) async {
    final pid = p.playlistId;

    final action = await showModalBottomSheet<String>(
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
            ListTile(
              title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w800)),
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
        builder: (_) => PlaylistDetailScreen(playlistId: p.playlistId),
      ),
    );
    await _load();
  }

  static String _songsCountLabel(PlaylistModel p) {
    if (p.songs == null) return "— songs";
    return "${p.songs!.length} songs";
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
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.more_horiz, color: Colors.black54),
            onPressed: () {},
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
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          children: [
            // ✅ Sort row (Recently Added có mũi tên xuống)
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
                      const SizedBox(width: 4),
                      const Icon(Icons.keyboard_arrow_down,
                          size: 18, color: Color(0xFF22C55E)),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Add new playlist
            _RowTile(
              leading: const CircleAvatar(
                radius: 22,
                backgroundColor: Color(0xFF22C55E),
                child: Icon(Icons.add, color: Colors.white),
              ),
              title: "Add New Playlist",
              subtitle: null,
              onTap: _createPlaylistDialog, // ✅ mở sheet giống hình
              trailing: const SizedBox(width: 24),
            ),
            const SizedBox(height: 6),

            // ✅ Your Likes
            _buildYourLikesTile(),
            const SizedBox(height: 6),

            // playlist items
            ..._playlists.map((p) {
              final isLikes = _isLikesPlaylist(p.name);
              return _RowTile(
                leading: _PlaylistThumb(
                  coverUrl: p.coverUrl,
                  isLikes: isLikes,
                ),
                title: p.name,
                subtitle: _songsCountLabel(p),
                onTap: () => _openDetail(p),
                trailing: IconButton(
                  icon: const Icon(Icons.more_vert, color: Colors.black54),
                  onPressed: () => _openPlaylistMenu(p),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

// =========================
// UI components
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
                  if (subtitle != null) ...[
                    const SizedBox(height: 3),
                    Text(subtitle!, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                  ],
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

class _PlaylistThumb extends StatelessWidget {
  final String? coverUrl;
  final bool isLikes;

  const _PlaylistThumb({required this.coverUrl, required this.isLikes});

  @override
  Widget build(BuildContext context) {
    if (coverUrl != null && coverUrl!.trim().isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          coverUrl!,
          width: 44,
          height: 44,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(),
        ),
      );
    }
    return _fallback();
  }

  Widget _fallback() {
    return CircleAvatar(
      radius: 22,
      backgroundColor: const Color(0xFFEFFDF5),
      child: Icon(
        isLikes ? Icons.favorite : Icons.queue_music,
        color: const Color(0xFF22C55E),
      ),
    );
  }
}

// =========================
// BottomSheet helpers
// =========================

Widget _sheetTextField({
  required TextEditingController controller,
  required String hint,
  bool enabled = true,
}) {
  return TextField(
    controller: controller,
    enabled: enabled,
    decoration: InputDecoration(
      hintText: hint,
      filled: true,
      fillColor: const Color(0xFFF7F7F7),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
      ),
      disabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE7E7E7)),
      ),
    ),
  );
}

Widget _sheetButton({
  required String label,
  required bool filled,
  required VoidCallback onTap,
}) {
  return SizedBox(
    height: 44,
    child: filled
        ? ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF22C55E),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        elevation: 0,
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    )
        : OutlinedButton(
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF22C55E),
        side: const BorderSide(color: Color(0xFF22C55E)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
      onPressed: onTap,
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w900)),
    ),
  );
}
