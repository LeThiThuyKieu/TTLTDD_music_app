import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';
import 'mini_player.dart';

/// Scaffold wrapper có tích hợp MiniPlayer ở dưới cùng
/// Dùng cho các màn hình chi tiết cần hiển thị MiniPlayer
class ScaffoldWithMiniPlayer extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Color? backgroundColor;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;

  const ScaffoldWithMiniPlayer({
    super.key,
    this.appBar,
    required this.body,
    this.backgroundColor,
    this.floatingActionButton,
    this.bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    final audioPlayer = context.watch<AudioPlayerService>();
    final hasSong = audioPlayer.currentSong != null;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: Stack(
        children: [
          // Body chính
          Positioned.fill(
            child: body,
          ),

          // Mini Player ở dưới cùng
          if (hasSong)
            const Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: MiniPlayer(),
            ),
        ],
      ),
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}
