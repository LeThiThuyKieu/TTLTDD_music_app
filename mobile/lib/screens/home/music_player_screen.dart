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
    /// PageView dùng để vuốt giữa Info / Disc / Lyrics
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

        /// ===== PLAYER SCREEN =====
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
                    /// Thông tin bài hát
                    InfoWidget(song: song),

                    /// Đĩa nhạc xoay
                    DiscWidget(
                      song: song,
                      isPlaying: audioService.isPlaying,
                    ),

                    /// Lời bài hát
                    LyricsWidget(
                      lyrics: song.lyrics ?? 'Chưa có lời bài hát',
                    ),
                  ],
                ),
              ),

              /// ===== BOTTOM CONTROL =====
              BottomControl(
                onPrevious: audioService.playPrevious,
                onNext: audioService.playNext,
              ),
            ],
          ),
        );
      },
    );
  }
}
