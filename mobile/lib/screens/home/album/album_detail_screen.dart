import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../models/album_model.dart';
import '../../../models/song_model.dart';
import '../../../services/album_service.dart';
import '../../../services/audio_player_service.dart';
import '../../../widgets/song_item.dart';
import '../../home/song_list_screen.dart';
import '../../home/artist/artist_detail_screen.dart';

class AlbumDetailScreen extends StatefulWidget {
  final AlbumModel album;

  const AlbumDetailScreen({super.key, required this.album});

  @override
  State<AlbumDetailScreen> createState() => _AlbumDetailScreenState();
}

class _AlbumDetailScreenState extends State<AlbumDetailScreen> {
  final AlbumService _albumService = AlbumService();
  bool isLoading = true;
  List<SongModel> songs = [];

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }

  Future<void> _loadSongs() async {
    try {
      final list = await _albumService.getSongsByAlbum(widget.album.albumId!);
      setState(() {
        songs = list;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Load album songs error: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        title: Text(widget.album.title),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Center(
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 220,
                    height: 220,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.12),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    //Ảnh album
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        widget.album.coverUrl ?? '',
                        width: 220,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          width: 220,
                          height: 220,
                          color: Colors.grey.shade300,
                        ),
                      ),
                    ),
                  ),
                  if (widget.album.artist?.avatarUrl != null &&
                      widget.album.artist!.avatarUrl!.isNotEmpty)
                    Positioned(
                      left: -18,
                      bottom: -18,
                      child: CircleAvatar(
                        radius: 36,
                        backgroundColor: Colors.white,
                        backgroundImage:
                            NetworkImage(widget.album.artist!.avatarUrl!),
                      ),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // tiêu đề, tên artist, date phát hành
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    widget.album.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),

                  // tên artist
                  GestureDetector(
                    onTap: widget.album.artist != null
                        ? () async {
                            final artist = widget.album.artist!;
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ArtistDetailScreen(
                                  artist: artist,
                                  popularSongs: [],
                                ),
                              ),
                            );
                          }
                        : null,
                    child: Text(
                      widget.album.artist?.name ?? 'Không rõ nghệ sĩ',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  //date phát hành
                  Text(
                    widget.album.releaseDate != null
                        ? (() {
                            final d = widget.album.releaseDate!.toLocal();
                            final day = d.day.toString().padLeft(2, '0');
                            final month = d.month.toString().padLeft(2, '0');
                            final year = d.year.toString();
                            return '$day-$month-$year';
                          })()
                        : '',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),

                  const SizedBox(height: 12),

                  // header: Bài hát | Xem tất cả
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8.0, vertical: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Bài hát',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.w700),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => SongListScreen(songs: songs),
                              ),
                            );
                          },
                          child: const Text(
                            'Xem tất cả',
                            style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),

            // songs list
            if (isLoading)
              const Center(
                  child: CircularProgressIndicator(color: Color(0xFF4CAF50)))
            else
              ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: songs.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final song = songs[index];
                  return SongItem(
                    song: song,
                    onPlay: () =>
                        context.read<AudioPlayerService>().playSong(song),
                    onTap: () {
                      debugPrint('Open song: ${song.title}');
                    },
                  );
                },
              ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
