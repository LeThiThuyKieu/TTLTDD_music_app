import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import '../services/auth_service.dart';
import '../services/playlist_api.dart';
import '../../widgets/song_item.dart';
class InfoWidget extends StatefulWidget {
  final SongModel song;
  final String? albumName;
  final String? genreName;

  const InfoWidget({
    super.key,
    required this.song,
    this.albumName,
    this.genreName,
  });

  @override
  State<InfoWidget> createState() => _InfoWidgetState();
}

class _InfoWidgetState extends State<InfoWidget> {
  List<SongModel> _suggestSongs = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadFromBE();
    });
  }

  Future<void> _loadFromBE() async {
    try {
      final token = await context.read<AuthService>().getToken();
      if (token == null) {
        setState(() => _loading = false);
        return;
      }

      final songs = await PlaylistApi.getPlaylistsBySong(
        songId: widget.song.songId!,
        token: token,
      );

      setState(() {
        _suggestSongs = songs;
        _loading = false;
      });
    } catch (e) {
      debugPrint('Load suggested songs error: $e');
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }


  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioPlayerService>();
    final playlist = audio.currentPlaylist;

    // ưu tiên bài đang phát từ service
    final song = audio.currentSong ?? widget.song;

    return SafeArea(
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F9F1),
              Colors.white,
            ],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                song.title,
                style: const TextStyle(
                  color: Colors.black,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              if (song.artists.isNotEmpty)
                Text(
                  song.artists.map((e) => e.name).join(', '),
                  style: const TextStyle(
                    color: Colors.black87,
                    fontSize: 18,
                  ),
                ),

              // 👇 dùng dữ liệu từ màn hình detail
              if (widget.albumName != null && widget.albumName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    'Album: ${widget.albumName}',
                    style:
                    const TextStyle(color: Colors.black87,
                      fontSize: 18,),
                  ),
                ),

              if (widget.genreName != null && widget.genreName!.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Thể loại: ${widget.genreName}',
                    style:
                    const TextStyle(color: Colors.black87,
                      fontSize: 18,),
                  ),
                ),

              if (song.releaseDate != null)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    'Phát hành: ${song.releaseDate!.toLocal().toString().split(' ').first}',
                    style:
                    const TextStyle(color: Colors.black87,
                      fontSize: 18,),
                  ),
                ),

              const SizedBox(height: 16),

              if (playlist != null && playlist.isNotEmpty)
                GestureDetector(
                  onTap: () => _showQueue(context, playlist),
                  child: const Row(
                    children: [
                      Icon(Icons.queue_music,
                          color: Colors.black54, size: 22),
                      SizedBox(width: 8),
                      Text(
                        'Danh sách phát',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              const Text(
                'Bài hát đề xuất',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 10),

              if (_loading)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 24),
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_suggestSongs.isEmpty)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 28),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Icon(Icons.music_off,
                          size: 36, color: Colors.black38),
                      SizedBox(height: 8),
                      Text(
                        "Chưa có bài hát nào liên quan",
                        style:
                        TextStyle(color: Colors.black54, fontSize: 16),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  children: _suggestSongs
                      .map(
                        (s) => SongItem(
                      song: s,
                      onPlay: () {
                        audio.playSongFromPlaylist([s], 0);
                      },
                      onTap: () {
                        audio.playSongFromPlaylist([s], 0);
                      },
                    ),
                  )
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }


  void _showQueue(BuildContext context, List<SongModel> playlist) {
    final audio = context.read<AudioPlayerService>();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => ListView.builder(
        itemCount: playlist.length,
        itemBuilder: (context, index) {
          final s = playlist[index];
          final isCurrent = index == audio.currentIndex;

          return ListTile(
            leading: Icon(
              isCurrent ? Icons.play_arrow : Icons.music_note,
              color: isCurrent ? Colors.green : Colors.black54,
            ),
            title: Text(
              s.title,
              style: TextStyle(
                color: isCurrent ? Colors.green : Colors.black,
                fontWeight:
                isCurrent ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            subtitle: Text(
              s.artists.map((e) => e.name).join(', '),
              style: const TextStyle(color: Colors.black45),
            ),
            onTap: () {
              audio.playSongFromPlaylist(playlist, index);
              Navigator.pop(context);
            },
          );
        },
      ),
    );
  }
}
