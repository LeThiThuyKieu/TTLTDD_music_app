import 'package:flutter/material.dart';

class LyricsWidget extends StatelessWidget {
  final String? lyrics;

  const LyricsWidget({
    super.key,
    required this.lyrics,
  });

  @override
  Widget build(BuildContext context) {
    final hasLyrics = lyrics != null && lyrics!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF0F9F1),
            Colors.white,
          ],
        ),
      ),
      child: SafeArea(
        child: !hasLyrics
            ? const Center(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              'Chưa có lời bài hát',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 34,
                fontWeight: FontWeight.w600,
                color: Color(0xFF9CA3AF),
                letterSpacing: 0.5,
              ),
            ),
          ),
        )
            : SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 40, 24, 48),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Text(
                lyrics!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF2A2F36),
                  fontSize: 24,
                  height: 2.0,
                  letterSpacing: 0.4,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}