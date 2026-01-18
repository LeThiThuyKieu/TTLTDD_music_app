import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../services/audio_player_service.dart';
import '../../widgets/info_widget.dart';
import '../../widgets/disc_widget.dart';
import '../../widgets/lyrics_widget.dart';
import '../../widgets/bottom_control.dart';

class MusicPlayerScreen extends StatelessWidget {
  const MusicPlayerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final PageController pageController =
    PageController(initialPage: 1);

    return Consumer<AudioPlayerService>(
      builder: (context, audioService, child) {
        final song = audioService.currentSong;

        if (song == null) {
          return const Scaffold(
            body: Center(child: Text("Chọn một bài hát để phát")),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Column(
            children: [
              /// ===== TOP CONTENT =====
              Expanded(
                child: PageView(
                  controller: pageController,
                  children: [
                    InfoWidget(song: song),
                    DiscWidget(
                      song: song,
                      isPlaying: audioService.isPlaying,
                    ),
                    LyricsWidget(
                      lyrics: song.lyrics ?? 'Chưa có lời bài hát',
                    ),
                  ],
                ),
              ),

              /// ===== BOTTOM CONTROL =====
              BottomControl(
                isPlaying: audioService.isPlaying,
                isShuffle: audioService.isShuffle,
                current: audioService.currentPosition,
                total: audioService.totalDuration,

                onPlayPause: () {
                  audioService.isPlaying
                      ? audioService.pause()
                      : audioService.resume();
                },

                onPrevious: audioService.playPrevious,
                onNext: audioService.playNext,

                onShuffle: audioService.toggleShuffle,
                onSeek: audioService.seek,
              ),
            ],
          ),
        );
      },
    );
  }
}
