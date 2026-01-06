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

  /// Playlist hiện tại (nếu phát từ playlist)
  List<SongModel>? _currentPlaylist;

  /// Index bài hát hiện tại trong playlist
  int _currentIndex = 0;

  List<SongModel>? get currentPlaylist => _currentPlaylist;
  int get currentIndex => _currentIndex;

  /// Thời gian hiện tại của bài hát
  Duration _currentPosition = Duration.zero;

  /// Tổng thời lượng bài hát
  Duration _totalDuration = Duration.zero;

  SongModel? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  AudioPlayerService() {
    // Khi bài hát kết thúc
    _player.onPlayerComplete.listen((_) async {
      // Nếu có playlist, phát bài tiếp theo
      if (_currentPlaylist != null &&
          _currentIndex < _currentPlaylist!.length - 1) {
        _currentIndex++;
        await playSong(_currentPlaylist![_currentIndex]);
      } else {
        // Không còn bài nào -> dừng nhạc
        _isPlaying = false;
        notifyListeners();
      }
    });

    /// Theo dõi thời gian hiện tại
    _player.onPositionChanged.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });

    /// Theo dõi tổng thời lượng
    _player.onDurationChanged.listen((duration) {
      _totalDuration = duration;
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

  /// Phát nhạc từ playlist, bắt đầu tại index
  Future<void> playSongFromPlaylist(
      List<SongModel> playlist, int startIndex) async {

    if (playlist.isEmpty) return;
    if (startIndex < 0 || startIndex >= playlist.length) return;

    _currentPlaylist = playlist;
    _currentIndex = startIndex;

    await playSong(playlist[startIndex]); // 👈 dùng lại hàm cũ
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

  /// Stop bài hát
  Future<void> stop() async {
    await _player.stop();
    _isPlaying = false;
    _currentPosition = Duration.zero;
    notifyListeners();
  }

  /// Seek đến vị trí bất kỳ
  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _currentPosition = position;
    notifyListeners();
  }

  /// Phát bài tiếp theo trong playlist (nếu có)
  Future<void> playNext() async {
    if (_currentPlaylist != null &&
        _currentIndex < _currentPlaylist!.length - 1) {
      _currentIndex++;
      await playSong(_currentPlaylist![_currentIndex]);
    }
  }

  /// Phát bài trước trong playlist (nếu có)
  Future<void> playPrevious() async {
    if (_currentPlaylist != null && _currentIndex > 0) {
      _currentIndex--;
      await playSong(_currentPlaylist![_currentIndex]);
    }
  }
  /// Có đang phát từ playlist không
  bool get isPlayingFromPlaylist =>
      _currentPlaylist != null && _currentPlaylist!.isNotEmpty;

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
