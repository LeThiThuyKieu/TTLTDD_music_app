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

        /// ===== CHƯA CHỌN BÀI HÁT =====
        if (song == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text("Music Player"),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: const Center(
              child: Text("Chọn một bài hát để phát"),
            ),
          );
        }

        /// ===== PLAYER =====
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            backgroundColor: const Color(0xFFF0F9F1),
            elevation: 0,
            toolbarHeight: 30,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
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
                      lyrics:
                          song.lyrics ?? 'Chưa có lời bài hát',
                    ),
                  ],
                ),
              ),

              /// ===== BOTTOM CONTROL =====
              BottomControl(
                // isPlaying: audioService.isPlaying,
                // isShuffle: audioService.isShuffle,
                // current: audioService.currentPosition,
                // total: audioService.totalDuration,
                //
                // onPlayPause: () {
                //   audioService.isPlaying
                //       ? audioService.pause()
                //       : audioService.resume();
                // },

                onPrevious: audioService.playPrevious,
                onNext: audioService.playNext,

                // onPrevious: audioService.playPrevious,
                // onNext: audioService.playNext,
                // onShuffle: audioService.toggleShuffle,
                // onSeek: audioService.seek,
                // onShuffle: audioService.toggleShuffle,
                // onSeek: audioService.seek,
              ),
            ],
          ),
        );
      },
    );
  }
}
