import 'dart:io';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class AudioPreviewPlayer extends StatefulWidget {
  final File? localFile;
  final String? networkUrl;

  const AudioPreviewPlayer({
    super.key,
    this.localFile,
    this.networkUrl,
  });

  @override
  State<AudioPreviewPlayer> createState() => _AudioPreviewPlayerState();
}

class _AudioPreviewPlayerState extends State<AudioPreviewPlayer> {
  final AudioPlayer _player = AudioPlayer();

  bool isPlaying = false;
  bool isLoading = false;

  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Lắng nghe tổng thời lượng
    _player.durationStream.listen((d) {
      if (d != null) {
        setState(() => _duration = d);
      }
    });

    // Lắng nghe vị trí đang phát
    _player.positionStream.listen((p) {
      setState(() => _position = p);
    });

    // Khi phát xong → reset icon
    _player.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
        setState(() => isPlaying = false);
      }
    });
  }

  @override
  void dispose() {
    _player.pause();
    _player.dispose();
    super.dispose();
  }

  Future<void> _togglePlay() async {
    try {
      if (_player.playing) {
        await _player.pause();
        setState(() => isPlaying = false);
        return;
      }

      setState(() => isLoading = true);

      if (widget.localFile != null) {
        await _player.setFilePath(widget.localFile!.path);
      } else if (widget.networkUrl != null) {
        await _player.setUrl(widget.networkUrl!);
      } else {
        return;
      }

      await _player.play();
      setState(() => isPlaying = true);
    } catch (e) {
      debugPrint('Audio play error: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  String _fileName() {
    if (widget.localFile != null) {
      return widget.localFile!.path.split('/').last;
    }
    if (widget.networkUrl != null) {
      return widget.networkUrl!.split('/').last;
    }
    return 'Chưa có file audio';
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    final m = two(d.inMinutes.remainder(60));
    final s = two(d.inSeconds.remainder(60));
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    if (widget.localFile == null && widget.networkUrl == null) {
      return const SizedBox();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8DB27C)),
      ),
      child: Column(
        children: [
          // ===== PLAY ROW =====
          Row(
            children: [
              InkWell(
                onTap: isLoading ? null : _togglePlay,
                borderRadius: BorderRadius.circular(50),
                child: Container(
                  width: 46,
                  height: 46,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF8DB27C),
                  ),
                  child: isLoading
                      ? const Padding(
                    padding: EdgeInsets.all(10),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                      : Icon(
                    isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Nghe thử audio',
                      style: TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _fileName(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // ===== PROGRESS BAR =====
          Slider(
            min: 0,
            max: _duration.inMilliseconds.toDouble(),
            value: _position.inMilliseconds
                .clamp(0, _duration.inMilliseconds)
                .toDouble(),
            activeColor: const Color(0xFF8DB27C),
            onChanged: (v) {
              _player.seek(Duration(milliseconds: v.toInt()));
            },
          ),

          // ===== TIME =====
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _format(_position),
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                _format(_duration),
                style: const TextStyle(fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
