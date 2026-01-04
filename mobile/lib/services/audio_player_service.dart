import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song_model.dart';
import '../config/api_config.dart';

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  /// Bài hát đang phát
  SongModel? _currentSong;

  /// Trạng thái phát
  bool _isPlaying = false;

  SongModel? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;

  AudioPlayerService() {
    // Khi bài hát kết thúc
    _player.onPlayerComplete.listen((_) {
      _isPlaying = false;
      notifyListeners();
    });

    // Optional: handle player state changes (buffering, playing...)
  }

  // Gọi khi bấm Play ở Home / SongList
  Future<void> playSong(SongModel song) async {
    try {
      // STOP trước nếu có bài đang chạy
      await _player.stop();

      _currentSong = song;
      _isPlaying = true;
      notifyListeners();

      // Tạo URL đầy đủ vì file URL là relative
      final raw = song.fileUrl;
      String sourceUrl = raw;

      if (!raw.startsWith('http')) {
        // ApiConfig.baseUrl ví dụ: http://10.0.2.2:3000/api
        // fileUrl trong DB có thể là '/uploads/audio/...' hoặc 'uploads/audio/...'
        // Ghép lại để được: http://10.0.2.2:3000/api/uploads/...
        if (raw.startsWith('/')) {
          sourceUrl = '${ApiConfig.baseUrl}$raw';
        } else {
          sourceUrl = '${ApiConfig.baseUrl}/$raw';
        }
      }

      await _player.play(UrlSource(sourceUrl));
    } catch (e) {
      // Nếu lỗi, reset trạng thái
      _isPlaying = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Pause nhạc
  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  /// Resume nhạc
  Future<void> resume() async {
    await _player.resume();
    _isPlaying = true;
    notifyListeners();
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
