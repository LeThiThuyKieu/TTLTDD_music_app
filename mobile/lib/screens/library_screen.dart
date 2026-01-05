import 'package:flutter/material.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        titleSpacing: 16,
        title: Row(
          children: [
            const Icon(Icons.music_note, color: Color(0xFF22C55E)),
            const SizedBox(width: 8),
            Text(
              "My Library",
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: mở search
            },
            icon: const Icon(Icons.search, color: Colors.black54),
          ),
          IconButton(
            onPressed: () {
              // TODO: mở settings
            },
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
                  fontWeight: FontWeight.w700,
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: See All history
                },
                child: const Text(
                  "See All",
                  style: TextStyle(color: Color(0xFF22C55E)),
                ),
              ),
            ],
          ),

          // ===== HISTORY LIST =====
          SizedBox(
            height: 150,
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
                  // demo màu thay ảnh
                  color: index == 0
                      ? const Color(0xFF60A5FA)
                      : index == 1
                      ? const Color(0xFFF472B6)
                      : const Color(0xFF34D399),
                  onTap: () {
                    // TODO: mở item history
                  },
                );
              },
            ),
          ),

          const SizedBox(height: 18),

          // ===== MENU LIST (NO DOWNLOADS & PODCASTS) =====
          _MenuTile(
            icon: Icons.queue_music,
            title: "Playlists",
            onTap: () {
              // TODO: Navigator.push -> PlaylistListScreen
            },
          ),
          _MenuTile(
            icon: Icons.album_outlined,
            title: "Albums",
            onTap: () {
              // TODO: Navigator.push -> AlbumScreen
            },
          ),
          _MenuTile(
            icon: Icons.music_note_outlined,
            title: "Songs",
            onTap: () {
              // TODO: Navigator.push -> SongListScreen / All songs
            },
          ),
          _MenuTile(
            icon: Icons.person_outline,
            title: "Artists",
            onTap: () {
              // TODO: Navigator.push -> ArtistScreen
            },
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
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              offset: const Offset(0, 6),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ảnh (demo bằng màu)
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(color: color),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.black54, fontSize: 12),
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

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: const Color(0xFFEFFDF5),
          child: Icon(icon, color: const Color(0xFF22C55E)),
        ),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        trailing: const Icon(Icons.chevron_right, color: Colors.black38),
        onTap: onTap,
      ),
    );
  }
}
