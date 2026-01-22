import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/album_model.dart';
import '../../../services/album_service.dart';
import '../../../services/audio_player_service.dart';
import '../../../widgets/scaffold_with_mini_player.dart';
import 'album_detail_screen.dart';

class AlbumListScreen extends StatefulWidget {
  final List<AlbumModel>? albums;

  const AlbumListScreen({super.key, this.albums});

  @override
  State<AlbumListScreen> createState() => _AlbumListScreenState();
}

class _AlbumListScreenState extends State<AlbumListScreen> {
  final AlbumService _albumService = AlbumService();
  List<AlbumModel> _albums = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    if (widget.albums != null) {
      _albums = widget.albums!;
      isLoading = false;
    } else {
      _loadAlbums();
    }
  }

  Future<void> _loadAlbums() async {
    try {
      // simply call backend via home API or album service; AlbumService doesn't have list method so fallback to home api
      final service = AlbumService();
      final list = await service.getSongsByAlbum(0); // invalid usage but we will instead call /albums via existing home API in future
      // This is a placeholder; in practice HomeApiService.getHotAlbums provides albums list
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Load albums error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final audioPlayer = context.watch<AudioPlayerService>();
    final hasSong = audioPlayer.currentSong != null;

    return ScaffoldWithMiniPlayer(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Albums'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: Padding(
        padding: EdgeInsets.fromLTRB(16, 0, 16, hasSong ? 70 : 0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
            : GridView.builder(
                itemCount: _albums.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 16,
                  childAspectRatio: 0.78,
                ),
                itemBuilder: (context, index) {
                  final album = _albums[index];
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => AlbumDetailScreen(album: album),
                        ),
                      );
                    },
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        AspectRatio(
                          aspectRatio: 1,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Image.network(
                              album.coverUrl ?? '',
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                color: Colors.grey.shade300,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          album.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
