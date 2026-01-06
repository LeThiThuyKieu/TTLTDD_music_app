import 'package:flutter/material.dart';

class LyricsWidget extends StatelessWidget {
  final String lyrics;

  const LyricsWidget({super.key, required this.lyrics});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16),
      child: Text(lyrics, style: TextStyle(color: Colors.black, fontSize: 16)),
    );
  }
}
