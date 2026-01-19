import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/audio_player_service.dart';

class BottomControl extends StatelessWidget {
  final VoidCallback? onNext;
  final VoidCallback? onPrevious;

  const BottomControl({
    super.key,
    this.onNext,
    this.onPrevious,
  });

  // Format Duration thành mm:ss
  String format(Duration d) =>
      "${d.inMinutes}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final audio = context.watch<AudioPlayerService>();

    /// Nếu audio chưa load xong duration → fallback sang duration từ DB
    final fallbackDurationSeconds = audio.currentSong?.duration ?? 0;
    final effectiveTotal = audio.totalDuration.inMilliseconds > 0
        ? audio.totalDuration
        : Duration(seconds: fallbackDurationSeconds);

    final maxMs = effectiveTotal.inMilliseconds > 0
        ? effectiveTotal.inMilliseconds.toDouble()
        : 1.0;

    final currentMs = audio.currentPosition.inMilliseconds
        .clamp(0, maxMs.toInt())
        .toDouble();

    const Color lightGreen = Color(0xFF81C784);

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, -4),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ===== Slider =====
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: lightGreen,
              inactiveTrackColor: lightGreen.withOpacity(0.25),
              thumbColor: lightGreen,
            ),
            child: Slider(
              min: 0,
              max: maxMs,
              value: currentMs,
              onChanged: (value) =>
                  audio.seek(Duration(milliseconds: value.toInt())),
            ),
          ),

          /// ===== Time =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  format(audio.currentPosition),
                  style:
                      const TextStyle(fontSize: 11, color: Colors.black45),
                ),
                Text(
                  format(effectiveTotal),
                  style:
                      const TextStyle(fontSize: 11, color: Colors.black45),
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          /// ===== Control Buttons =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Shuffle
              IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: audio.isShuffle ? lightGreen : Colors.black45,
                ),
                onPressed: audio.toggleShuffle,
              ),

              const SizedBox(width: 6),

              /// Previous
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.skip_previous_rounded),
                color: Colors.black54,
                onPressed: onPrevious ?? audio.playPrevious,
              ),

              const SizedBox(width: 12),

              /// Play / Pause
              GestureDetector(
                onTap: audio.isPlaying ? audio.pause : audio.resume,
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: lightGreen,
                    boxShadow: [
                      BoxShadow(
                        color: lightGreen.withOpacity(0.45),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      )
                    ],
                  ),
                  child: Icon(
                    audio.isPlaying
                        ? Icons.pause_rounded
                        : Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// Next
              IconButton(
                iconSize: 36,
                icon: const Icon(Icons.skip_next_rounded),
                color: Colors.black54,
                onPressed: onNext ?? audio.playNext,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
