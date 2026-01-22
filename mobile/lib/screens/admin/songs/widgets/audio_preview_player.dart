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

    _player.durationStream.listen((d) {
      if (d != null) setState(() => _duration = d);
    });

    _player.positionStream.listen((p) {
      setState(() => _position = p);
    });

    _player.playerStateStream.listen((state) {
      setState(() {
        isPlaying = state.playing;
        isLoading = state.processingState == ProcessingState.loading ||
            state.processingState == ProcessingState.buffering;
      });

      if (state.processingState == ProcessingState.completed) {
        _player.seek(Duration.zero);
        _player.pause();
      }
    });
  }

  @override
  void didUpdateWidget(covariant AudioPreviewPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);

    final fileChanged =
        widget.localFile?.path != oldWidget.localFile?.path;
    final urlChanged =
        widget.networkUrl != oldWidget.networkUrl;

    if (fileChanged || urlChanged) {
      _resetPlayer();
    }
  }

  Future<void> _resetPlayer() async {
    await _player.stop();
    await _player.seek(Duration.zero);
    setState(() {
      _duration = Duration.zero;
      _position = Duration.zero;
    });
  }

  Future<void> _togglePlay() async {
    if (_player.playing) {
      await _player.pause();
      return;
    }

    if (_player.audioSource == null) {
      if (widget.localFile != null) {
        await _player.setFilePath(widget.localFile!.path);
        // đọc file MP3 trực tiếp từ ổ cứng máy rồi phát nhạc
      } else if (widget.networkUrl != null) {
        await _player.setUrl(widget.networkUrl!);
        // mở stream HTTP và just_audio bắt đầu bufer vài giây đầu để phát nhạc
      //just_audio.setUrl() dùng streaming + buffer, không download file
      }
    }

    await _player.play();
  }

  String _format(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes)}:${two(d.inSeconds.remainder(60))}';
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.localFile == null && widget.networkUrl == null) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF8DB27C)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              InkWell(
                onTap: isLoading ? null : _togglePlay,
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
              const SizedBox(width: 12),
              const Text(
                'Nghe audio',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          Slider(
            min: 0,
            max: _duration.inMilliseconds.toDouble(),
            value: _position.inMilliseconds
                .clamp(0, _duration.inMilliseconds)
                .toDouble(),
            onChanged: (v) {
              _player.seek(Duration(milliseconds: v.toInt()));
            },
            activeColor: const Color(0xFF8DB27C),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_format(_position)),
              Text(_format(_duration)),
            ],
          ),
        ],
      ),
    );
  }
}
