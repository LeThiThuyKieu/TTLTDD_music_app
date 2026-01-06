import 'package:flutter/material.dart';

class LyricsWidget extends StatelessWidget {
  final String? lyrics;

  const LyricsWidget({
    super.key,
    required this.lyrics,
  });

  @override
  Widget build(BuildContext context) {
    // Kiểm tra có lyrics hay không
    final hasLyrics = lyrics != null && lyrics!.trim().isNotEmpty;

    return Container(
        width: double.infinity,
        height: double.infinity, // Đảm bảo nền phủ toàn bộ diện tích
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFFF0F9F1), // Xanh lá cực nhạt (Mint Cream)
              Colors.white,      // Kết thúc bằng màu trắng
            ],
          ),
        ),
    child: !hasLyrics
    ? const Center(
        child: Text(
          'Chưa có lời bài hát',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.bold,
            color: Colors.black38,
          ),
        ),
    )

    : SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Text(
        lyrics!,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 20,
          height: 1.5,
        ),
      ),
    ),
    );
  }
}
