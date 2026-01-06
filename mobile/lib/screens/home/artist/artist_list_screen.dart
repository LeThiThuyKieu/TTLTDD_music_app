import 'package:flutter/material.dart';
import '../../../models/artist_model.dart';
import '../../../services/artist_service.dart';
import 'artist_detail_screen.dart';

class ArtistListScreen extends StatefulWidget {
  final List<ArtistModel> artists;

  const ArtistListScreen({
    super.key,
    required this.artists,
  });

  @override
  State<ArtistListScreen> createState() => _ArtistListScreenState();
}

class _ArtistListScreenState extends State<ArtistListScreen> {
  int? _pressedIndex;
  final ArtistService _artistService = ArtistService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      // ===== bar =====
      appBar: AppBar(
        title: const Text(
          'Nghệ sĩ nổi bật',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        centerTitle: false,
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: Icon(Icons.search),
          ),
        ],
      ),

      // ===== danh sach artist =====
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: GridView.builder(
          itemCount: widget.artists.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 16,
            childAspectRatio: 0.78,
          ),
          itemBuilder: (context, index) {
            final artist = widget.artists[index];
            final isPressed = _pressedIndex == index;

            return GestureDetector(
              onTapDown: (_) {
                setState(() => _pressedIndex = index);
              },
              onTapUp: (_) async {
                setState(() => _pressedIndex = null);
                final currentContext = context;
                final songs = await _artistService.getSongsByArtist(
                  artist.artistId!,
                  limit: 20,
                );
                if (!mounted) return;
                Navigator.push(
                  currentContext,
                  MaterialPageRoute(
                    builder: (_) => ArtistDetailScreen(
                      artist: artist,
                      popularSongs: songs,
                    ),
                  ),
                );
              },
              onTapCancel: () {
                setState(() => _pressedIndex = null);
              },
              child: AnimatedScale(
                scale: isPressed ? 0.95 : 1.0,
                duration: const Duration(milliseconds: 120),
                curve: Curves.easeOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // ===== avatar =====
                    AspectRatio(
                      aspectRatio: 1,
                      child: ClipOval(
                        child: Image.network(
                          artist.avatarUrl ?? '',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: Colors.grey.shade300,
                            alignment: Alignment.center,
                            child: const Icon(
                              Icons.person,
                              size: 48,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // ===== Tên nghệ sĩ =====
                    Text(
                      artist.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
