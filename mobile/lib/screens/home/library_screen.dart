import 'package:flutter/material.dart';
import '../playlist_list_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  static const _green = Color(0xFF22C55E);
  static const _bg = Color(0xFFF6F7F8);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.white,
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.music_note, color: _green),
            const SizedBox(width: 8),
            Text(
              "My Library",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.black54),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.settings_outlined, color: Colors.black54),
          ),
          const SizedBox(width: 6),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        children: [
          // ===== YOUR HISTORY HEADER =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Your History",
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: _green,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                child: const Text("See All"),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // ===== HISTORY LIST =====
          SizedBox(
            height: 156,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 3,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                return _HistoryCard(
                  title: index == 0
                      ? "Jordan Harbinger"
                      : index == 1
                      ? "Apple Talk"
                      : "Shades of...",
                  subtitle: index == 0
                      ? "610: Bill Sullivan..."
                      : index == 1
                      ? "Apple Talk"
                      : "Ania S...",
                  color: index == 0
                      ? const Color(0xFF60A5FA)
                      : index == 1
                      ? const Color(0xFFF472B6)
                      : const Color(0xFF34D399),
                  onTap: () {},
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // ===== MENU ===== (đã xóa Downloads + Podcasts)
          _MenuTile(
            icon: Icons.queue_music,
            title: "Playlists",
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const PlaylistListScreen()),
              );
            },
          ),
          _MenuTile(
            icon: Icons.album_outlined,
            title: "Albums",
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.music_note_outlined,
            title: "Songs",
            onTap: () {},
          ),
          _MenuTile(
            icon: Icons.person_outline,
            title: "Artists",
            onTap: () {},
          ),
        ],
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _HistoryCard({
    required this.title,
    required this.subtitle,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: onTap,
      child: SizedBox(
        width: 120,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // image
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Container(color: color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                color: Colors.black54,
                fontSize: 12,
                height: 1.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _MenuTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  static const _green = Color(0xFF22C55E);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFEFFDF5),
          child: Icon(icon, color: _green),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black38),
        onTap: onTap,
      ),
    );
  }
}
