import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/song_model.dart';
import '../../services/audio_player_service.dart';
import '../../widgets/info_widget.dart';
import '../../widgets/disc_widget.dart';
import '../../widgets/lyrics_widget.dart';
import '../../widgets/bottom_control.dart';
//Huong
class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({super.key});

  String formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes.remainder(60))}:${twoDigits(d.inSeconds.remainder(60))}";
  }

  @override
  Widget build(BuildContext context) {
      final PageController _pageController =
      PageController(initialPage: 1);
    return Consumer<AudioPlayerService>(
      builder: (context, audioService, child) {
        final song = audioService.currentSong;

        if (song == null) {
          return Scaffold(
            appBar: AppBar(title: Text("Music Player")),
            body: Center(child: Text("Chọn một bài hát để phát")),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  children: [
                    InfoWidget(song: song),
                    DiscWidget(song: song, isPlaying: audioService.isPlaying),
                    LyricsWidget(lyrics: song.lyrics ?? 'Null'),
                  ],
                ),
              ),
              BottomControl(
                isPlaying: audioService.isPlaying,
                current: audioService.currentPosition,
                total: audioService.totalDuration,

                onPlayPause: () {
                  audioService.isPlaying
                      ? audioService.pause()
                      : audioService.resume();
                },

                onSeek: audioService.seek,

                onPrevious: () {
                  audioService.playPrevious();
                },

                onNext: () {
                  audioService.playNext();
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
