import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../services/audio_player_service.dart';
import '../services/auth_service.dart';
import '../services/playlist_api.dart';

class InfoWidget extends StatelessWidget {
  final SongModel song;
  final String? albumName; // tên album (có thể null)
  final String? genreName; // tên thể loại (có thể null)

  const InfoWidget({
    super.key,
    required this.song,
    this.albumName,
    this.genreName,
  });

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioPlayerService>();
    final playlist = audio.currentPlaylist; // List<SongModel>?

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        // Gradient chuyển từ xanh lá cực nhạt sang trắng tinh khôi
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF0F9F1), // Xanh lá rất nhạt (Mint Cream)
            Colors.white,             // Kết thúc bằng màu trắng
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 🎵 Tên bài hát
          Text(
            song.title,
            style: const TextStyle(
              color: Colors.black,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 6),

          // 🎤 Nghệ sĩ
          if (song.artists.isNotEmpty)
            Text(
              song.artists.map((e) => e.name).join(', '),
              style: const TextStyle(color: Colors.black54, fontSize: 16),
            ),

          // 📀 Album
          if (albumName != null && albumName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Album: $albumName',
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),

          // 🎶 Thể loại
          if (genreName != null && genreName!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Thể loại: $genreName',
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),

          // 📅 Ngày phát hành
          if (song.releaseDate != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'Phát hành: ${_formatDate(song.releaseDate!)}',
                style: const TextStyle(color: Colors.black54, fontSize: 16),
              ),
            ),

          const SizedBox(height: 12),

          // 📂 Queue hiện tại
          if (playlist != null && playlist.isNotEmpty)
            GestureDetector(
              onTap: () => _showQueue(context, playlist),
              child: const Row(
                children: [
                  Icon(Icons.queue_music, color: Colors.black54, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Danh sách phát',
                    style: TextStyle(
                      color: Colors.black54,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // 🎵 Playlist chứa bài hát từ BE
          GestureDetector(
            onTap: () => _showPlaylistsFromBE(context),
            child: const Row(
              children: [
                Icon(Icons.library_music, color: Colors.black54, size: 20),
                SizedBox(width: 8),
                Text(
                  'Playlist chứa bài hát này',
                  style: TextStyle(
                    color: Colors.black54,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2,'0')}/"
        "${date.month.toString().padLeft(2,'0')}/"
        "${date.year}";
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

  void _showPlaylistsFromBE(BuildContext context) async {
    final token = await context.read<AuthService>().getToken();
    if (token == null) return;

    // Show loading
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.black,
      builder: (_) => const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );

    try {
      final playlists = await PlaylistApi.getPlaylistsBySong(
        songId: song.songId!,
        token: token,
      );

      Navigator.pop(context); // remove loading sheet

      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
        ),
        builder: (_) => playlists.isEmpty
            ? SizedBox(
          height: 150,
          child: Center(
            child: Text(
              "Chưa có playlist nào chứa bài hát này",
              style: TextStyle(color: Colors.white, fontSize: 18),
              textAlign: TextAlign.center,
            ),
          ),
        )
            : ListView.builder(
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            final p = playlists[index];
            return ListTile(
              leading: const Icon(Icons.playlist_play,
                  color: Colors.white70),
              title: Text(p.name,
                  style: const TextStyle(color: Colors.white)),
              onTap: () {
                Navigator.pop(context);
              },
            );
          },
        ),
      );
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tải playlist: $e")),
      );
    }
  }
}
