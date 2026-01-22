import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/song_model.dart';
import '../../widgets/song_item.dart';
import '../../widgets/add_to_playlist_sheet.dart';
import '../../widgets/scaffold_with_mini_player.dart';
import '../../services/audio_player_service.dart';
import 'music_player_screen.dart';
import '../../services/favorite_api_service.dart';

class SongListScreen extends StatefulWidget {
  final List<SongModel> songs;

  const SongListScreen({
    super.key,
    required this.songs,
  });

  @override
  State<SongListScreen> createState() => _SongListScreenState();
}

class _SongListScreenState extends State<SongListScreen> {
  @override
  void initState() {
    super.initState();
    FavoriteApiService.instance.loadFavorites().catchError((_) {});
  }

  @override
  Widget build(BuildContext context) {
    final songs = widget.songs;
    final audioPlayer = context.watch<AudioPlayerService>();
    final hasSong = audioPlayer.currentSong != null;

    return ScaffoldWithMiniPlayer(
      appBar: AppBar(
        title: const Text('Bài hát'),
        centerTitle: false,
      ),
      body: ListView.builder(
        padding: EdgeInsets.only(bottom: hasSong ? 70 : 0),
        itemCount: songs.length,
        itemBuilder: (context, index) {
          final song = songs[index];

          return SongItem(
            song: song,
            onPlay: () {
              context.read<AudioPlayerService>().playSong(song);
            },
            onTap: () {
              // Phát bài và mở màn hình player đầy đủ
              context.read<AudioPlayerService>().playSong(song);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const MusicPlayerScreen(),
                ),
              );
            },
            onAddToPlaylist: () {
              showAddToPlaylistSheet(context, song);
            },
          );
        },
      ),
    );
  }
}
