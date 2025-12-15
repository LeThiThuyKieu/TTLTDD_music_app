import 'package:flutter/material.dart';
import '../models/song_model.dart';

class AudioPlayerService extends ChangeNotifier {
  /// Bài hát đang phát
  SongModel? _currentSong;

  /// Trạng thái phát
  bool _isPlaying = false;

  SongModel? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;

  /// Gọi khi bấm Play ở Home / SongList
  void playSong(SongModel song) {
    _currentSong = song;
    _isPlaying = true;

    notifyListeners();
  }

  /// Pause nhạc
  void pause() {
    _isPlaying = false;
    notifyListeners();
  }

  /// Resume nhạc
  void resume() {
    _isPlaying = true;
    notifyListeners();
  }
}
