import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../top_song.dart';

class TopSongsChart extends StatelessWidget {
  final List<TopSong> songs;
  const TopSongsChart({super.key, required this.songs});

  @override
  Widget build(BuildContext context) {
    final maxPlay =
    songs.map((e) => e.plays).reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EED9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Top bài hát nghe nhiều nhất'),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: songs.map((song) {
                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: 140 * (song.plays / maxPlay),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        song.title.length > 6
                            ? '${song.title.substring(0, 6)}...'
                            : song.title,
                        style: const TextStyle(fontSize: 10),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
