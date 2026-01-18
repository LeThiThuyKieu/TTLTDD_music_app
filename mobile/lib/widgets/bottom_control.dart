import 'package:flutter/material.dart';

class BottomControl extends StatelessWidget {
  final bool isPlaying;
  final bool isShuffle;

  final Duration current;
  final Duration total;

  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final VoidCallback onShuffle;
  final ValueChanged<Duration> onSeek;

  const BottomControl({
    super.key,
    required this.isPlaying,
    required this.isShuffle,
    required this.current,
    required this.total,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
    required this.onShuffle,
    required this.onSeek,
  });

  String format(Duration d) =>
      "${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {
    final maxSeconds =
    total.inSeconds > 0 ? total.inSeconds.toDouble() : 1.0;

    final currentSeconds =
    current.inSeconds.clamp(0, maxSeconds.toInt()).toDouble();

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 12,
            offset: Offset(0, -2),
          )
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ===== Slider =====
          Slider(
            min: 0,
            max: maxSeconds,
            value: currentSeconds,
            onChanged: (value) =>
                onSeek(Duration(seconds: value.toInt())),
            activeColor: Colors.green,
            inactiveColor: Colors.black12,
          ),

          /// ===== Time =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(format(current),
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
                Text(format(total),
                    style: const TextStyle(
                        fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// ===== Controls =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Shuffle
              IconButton(
                icon: Icon(
                  Icons.shuffle,
                  color: isShuffle ? Colors.green : Colors.black54,
                ),
                onPressed: onShuffle,
              ),

              /// Previous
              IconButton(
                iconSize: 34,
                icon: const Icon(Icons.skip_previous),
                onPressed: onPrevious,
              ),

              const SizedBox(width: 12),

              /// Play / Pause
              GestureDetector(
                onTap: onPlayPause,
                child: Container(
                  width: 68,
                  height: 68,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.green,
                  ),
                  child: Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 38,
                  ),
                ),
              ),

              const SizedBox(width: 12),

              /// Next
              IconButton(
                iconSize: 34,
                icon: const Icon(Icons.skip_next),
                onPressed: onNext,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
