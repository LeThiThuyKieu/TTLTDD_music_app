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

  String? get _coverUrl {
    final raw = widget.song.coverUrl;
    if (raw == null || raw.isEmpty) return null;
    return raw.startsWith('http') ? raw : '${ApiConfig.baseUrl}$raw';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(

        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFFF0F9F1),
            Colors.white,
          ],
        ),
      ),
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: RotationTransition(
                turns: _controller,
                child: Container(
                  width: 320,
                  height: 320,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    // Viền trắng mảnh giúp ảnh trông thanh lịch hơn
                    border: Border.all(
                      color: Colors.white,
                      width: 6,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.green.withOpacity(0.1), // Đổ bóng xanh nhẹ thay vì màu đen
                        blurRadius: 30,
                        spreadRadius: 2,
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
            ),
          ),

          const SizedBox(height: 30),

          // Tên bài hát - Dùng màu xám cực đậm (Soft Black) thay vì đen thuần
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Text(
              widget.song.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: Color(0xFF2C3E50),
                letterSpacing: -0.5,
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Nghệ sĩ - Dùng màu xanh lá đậm trung tính
          if (widget.song.artists.isNotEmpty)
            Text(
              widget.song.artists.map((e) => e.name).join(', '),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.green.shade700.withOpacity(0.7),
                fontWeight: FontWeight.w500,
              ),
            ),

          const SizedBox(height: 50),
        ],
      ),
    );
  }

// Cập nhật lại fallback (khi không có ảnh) cho đồng bộ tông màu nhạt
  Widget _fallback() {
    return Container(
      color: const Color(0xFFE8F5E9),
      child: Center(
        child: Icon(
          Icons.music_note_rounded,
          size: 80,
          color: Colors.green.withOpacity(0.3),
        ),
      ),
    );
  }
}
