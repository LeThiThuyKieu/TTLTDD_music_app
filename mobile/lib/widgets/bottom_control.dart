import 'package:flutter/material.dart';

class BottomControl extends StatelessWidget {
  final bool isPlaying;
  final Duration current;
  final Duration total;

  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;
  final Function(Duration) onSeek;

  const BottomControl({
    super.key,
    required this.isPlaying,
    required this.current,
    required this.total,
    required this.onPlayPause,
    required this.onSeek,
    required this.onNext,
    required this.onPrevious,
  });

  String format(Duration d) =>
      "${d.inMinutes.toString().padLeft(2, '0')}:${(d.inSeconds % 60).toString().padLeft(2, '0')}";

  @override
  Widget build(BuildContext context) {

    final maxMs = total.inMilliseconds > 0
        ? total.inMilliseconds.toDouble()
        : 1.0;
    final currentMs = current.inMilliseconds
        .clamp(0, maxMs.toInt())
        .toDouble();

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
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 3,
              thumbShape:
              const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape:
              const RoundSliderOverlayShape(overlayRadius: 12),
              activeTrackColor: Colors.green,
              inactiveTrackColor: Colors.black12,
              thumbColor: Colors.green,
            ),
            child: Slider(
              min: 0,
              max: maxMs,
              value: currentMs,
              onChanged: (value) {
                onSeek(Duration(milliseconds: value.toInt()));
              },
            ),
          ),

          /// ===== Time =====
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(format(current),
                    style:
                    const TextStyle(fontSize: 12, color: Colors.black54)),
                Text(format(total),
                    style:
                    const TextStyle(fontSize: 12, color: Colors.black54)),
              ],
            ),
          ),

          const SizedBox(height: 12),

          /// ===== Control buttons =====
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
