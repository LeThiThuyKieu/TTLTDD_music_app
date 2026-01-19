import 'dart:math';
import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../models/song_model.dart';
import '../config/api_config.dart';

class AudioPlayerService extends ChangeNotifier {
  final AudioPlayer _player = AudioPlayer();

  SongModel? _currentSong;
  bool _isPlaying = false;

  /// Playlist gốc (thứ tự ban đầu)
  List<SongModel>? _originalPlaylist;

  /// Playlist đang phát (có thể đã shuffle)
  List<SongModel>? _playQueue;

  int _currentIndex = 0;

  /// SHUFFLE
  bool _isShuffle = false;

  /// Flag để ngăn chặn các lệnh phát song trùng lặp
  bool _isLoadingSong = false;

  // ===== GETTERS =====
  SongModel? get currentSong => _currentSong;
  bool get isPlaying => _isPlaying;
  bool get isShuffle => _isShuffle;

  List<SongModel>? get currentPlaylist => _playQueue;
  int get currentIndex => _currentIndex;

  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;

  Duration get currentPosition => _currentPosition;
  Duration get totalDuration => _totalDuration;

  AudioPlayerService() {
    _player.onPlayerComplete.listen((_) {
      playNext();
    });

    _player.onPositionChanged.listen((pos) {
      _currentPosition = pos;
      notifyListeners();
    });

    _player.onDurationChanged.listen((duration) {
      _totalDuration = duration;
      notifyListeners();
    });
  }

  // ===== PLAY SINGLE SONG =====
  Future<void> playSong(SongModel song) async {
    // Ngăn chặn các lệnh phát song trùng lặp
    if (_isLoadingSong) {
      return;
    }

    _isLoadingSong = true;

    try {
      // Dừng bài hát hiện tại
      await _player.stop();

      // Đợi một chút để đảm bảo bài hát cũ hoàn toàn dừng
      await Future.delayed(const Duration(milliseconds: 100));

      _currentSong = song;
      _isPlaying = true;
      notifyListeners();

    String sourceUrl = song.fileUrl;
    if (!sourceUrl.startsWith('http')) {
      sourceUrl = sourceUrl.startsWith('/')
          ? '${ApiConfig.baseUrl}$sourceUrl'
          : '${ApiConfig.baseUrl}/$sourceUrl';
    }

    await _player.play(UrlSource(sourceUrl));
    } finally {
      _isLoadingSong = false;
    }
  }

  // ===== PLAY FROM PLAYLIST =====
  Future<void> playSongFromPlaylist(
    List<SongModel> playlist,
    int startIndex,
  ) async {
    if (playlist.isEmpty) return;

    // Ngăn chặn các lệnh phát song trùng lặp
    if (_isLoadingSong) {
      return;
    }
    _originalPlaylist = List.from(playlist);

    if (_isShuffle) {
      _playQueue = List.from(playlist)..shuffle(Random());
      _currentIndex = _playQueue!
          .indexWhere((s) => s.songId == playlist[startIndex].songId);
    } else {
      _playQueue = List.from(playlist);
      _currentIndex = startIndex;
    }

    await playSong(_playQueue![_currentIndex]);
  }

  // ===== SHUFFLE =====
  void toggleShuffle() {
    _isShuffle = !_isShuffle;

    if (_originalPlaylist == null || _currentSong == null) {
      notifyListeners();
      return;
    }

    if (_isShuffle) {
      _playQueue = List.from(_originalPlaylist!)..shuffle(Random());
    } else {
      _playQueue = List.from(_originalPlaylist!);
    }

    _currentIndex = _playQueue!
        .indexWhere((s) => s.songId == _currentSong!.songId);

    notifyListeners();
  }

  // ===== CONTROLS =====
  Future<void> playNext() async {
    if (_playQueue == null || _playQueue!.isEmpty) return;

    // if (_currentIndex < _playQueue!.length - 1) {
    //   _currentIndex++;
    // nếu ch tới bài cuối thì phát tiếp, bài cúi thì quay lại bào đầu tiên
    _currentIndex = (_currentIndex + 1) % _playQueue!.length;
      await playSong(_playQueue![_currentIndex]);
    // }
  }

  Future<void> playPrevious() async {
    if (_playQueue == null || _playQueue!.isEmpty) return;

    if (_currentIndex > 0) {
      _currentIndex--;
      await playSong(_playQueue![_currentIndex]);
    }
  }

  Future<void> pause() async {
    await _player.pause();
    _isPlaying = false;
    notifyListeners();
  }

  Future<void> resume() async {
    await _player.resume();
    _isPlaying = true;
    notifyListeners();
  }

  Future<void> seek(Duration position) async {
    await _player.seek(position);
    _currentPosition = position;
    notifyListeners();
  }

  /// Có đang phát từ playlist không
  bool get isPlayingFromPlaylist =>
      _playQueue != null && _playQueue!.isNotEmpty;

  /// Cập nhật bài hát hiện tại bằng bản đầy đủ (artists, album, genre...)
  void updateCurrentSongDetail(SongModel fullSong) {
    if (_currentSong == null) return;

    if (_currentSong!.songId == fullSong.songId) {
      _currentSong = fullSong;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }
}
