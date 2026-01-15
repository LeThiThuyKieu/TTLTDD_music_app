import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/song_model.dart';
import '../services/api_service.dart';
import '../services/audio_player_service.dart';
import '../services/favorite_api_service.dart';
import '../widgets/song_item.dart';
import '../widgets/add_to_playlist_sheet.dart';
import 'home/music_player_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  final ApiService _api = ApiService();

  bool _loading = true;
  String? _error;
  List<SongModel> _songs = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      // ✅ endpoint trả list SongModel
      final res = await _api.get('/favorites/songs');
      final data = (res['data'] ?? res) as dynamic;

      final list = <SongModel>[];
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            list.add(SongModel.fromJson(item));
          }
        }
      }

      // ✅ sync icon tim trên UI
      await FavoriteApiService.instance.loadFavorites();

      setState(() {
        _songs = list;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bài hát yêu thích')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Lỗi: $_error'))
          : _songs.isEmpty
          ? const Center(child: Text('Chưa có bài hát yêu thích'))
          : RefreshIndicator(
        onRefresh: _load,
        child: ListView.builder(
          itemCount: _songs.length,
          itemBuilder: (context, index) {
            final song = _songs[index];
            return SongItem(
              song: song,
              onPlay: () =>
                  context.read<AudioPlayerService>().playSong(song),
              onTap: () {
                context.read<AudioPlayerService>().playSong(song);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const MusicPlayerScreen(),
                  ),
                );
              },
              onAddToPlaylist: () =>
                  showAddToPlaylistSheet(context, song),
            );
          },
        ),
      ),
    );
  }
}
