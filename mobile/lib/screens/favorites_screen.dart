import 'package:flutter/material.dart';
import '../models/song_model.dart';
import '../services/api_service.dart';
import '../services/favorite_api_service.dart';
import '../widgets/song_item.dart';
import '../widgets/add_to_playlist_sheet.dart';

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
      // Load danh sách bài hát yêu thích
      final res = await _api.get('/favorites');
      final data = (res['data'] ?? res) as dynamic;

      final list = <SongModel>[];
      if (data is List) {
        for (final item in data) {
          if (item is Map<String, dynamic>) {
            list.add(SongModel.fromJson(item));
          }
        }
      }

      //  Load danh sách favorite ids (để sync toàn app)
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
          : ValueListenableBuilder<Set<int>>(
        valueListenable:
        FavoriteApiService.instance.favoriteSongIds,
        builder: (context, favIds, _) {
          //  lọc lại list theo favorite hiện tại
          final filteredSongs = _songs
              .where((s) =>
          s.songId != null &&
              favIds.contains(s.songId))
              .toList();

          if (filteredSongs.isEmpty) {
            return const Center(
              child: Text('Chưa có bài hát yêu thích'),
            );
          }

          return RefreshIndicator(
            onRefresh: _load,
            child: ListView.builder(
              itemCount: filteredSongs.length,
              itemBuilder: (context, index) {
                final song = filteredSongs[index];

                return SongItem(
                  song: song,
                  onPlay: () =>
                      debugPrint('Play: ${song.title}'),
                  onTap: () =>
                      debugPrint('Open player: ${song.title}'),
                  onAddToPlaylist: () =>
                      showAddToPlaylistSheet(context, song),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
