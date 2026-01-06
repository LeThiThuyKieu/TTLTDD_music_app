import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../config/api_config.dart';

class DiscWidget extends StatefulWidget {
  final SongModel song;
  final bool isPlaying;

  const DiscWidget({
    super.key,
    required this.song,
    required this.isPlaying,
  });

  @override
  State<DiscWidget> createState() => _DiscWidgetState();
}

class _DiscWidgetState extends State<DiscWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 20),
    );

    if (widget.isPlaying) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant DiscWidget oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isPlaying && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.isPlaying && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  /// 🔗 Ghép URL ảnh bài hát
  String? get _coverUrl {
    final raw = widget.song.coverUrl;
    if (raw == null || raw.isEmpty) return null;

    return raw.startsWith('http')
        ? raw
        : '${ApiConfig.baseUrl}$raw';
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: RotationTransition(
        turns: _controller,
        child: Container(
          width: 350,
          height: 350,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipOval(
            child: _coverUrl != null
                ? Image.network(
              _coverUrl!,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _fallback(),
            )
                : _fallback(),
          ),
        ),
      ),
    );
  }

  /// 🎵 Icon fallback khi không có ảnh
  Widget _fallback() {
    return Container(
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(
          Icons.music_note,
          size: 80,
          color: Colors.black54,
        ),
      ),
    );
  }
}
