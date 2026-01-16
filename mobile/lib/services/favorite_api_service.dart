import 'package:flutter/foundation.dart';
import 'api_service.dart';

class FavoriteApiService {
  FavoriteApiService._();
  static final FavoriteApiService instance = FavoriteApiService._();

  final ApiService _api = ApiService();

  /// Cache songIds đã tim
  final ValueNotifier<Set<int>> favoriteSongIds = ValueNotifier<Set<int>>({});

  /// Load favorites từ server
  Future<void> loadFavorites() async {
    final res = await _api.get('/favorites');

    // Tùy backend, có thể data nằm ở res['data']
    final data = (res['data'] ?? res) as dynamic;

    final ids = <int>{};

    // Backend có thể trả:
    // - [1,2,3]
    // - [{song_id:1}, ...]
    // - [{songId:1}, ...]
    // - [{id:1}, ...]
    if (data is List) {
      for (final item in data) {
        if (item is int) {
          ids.add(item);
        } else if (item is Map) {
          final raw = item['song_id'] ?? item['songId'] ?? item['id'];
          final sid = int.tryParse(raw?.toString() ?? '');
          if (sid != null) ids.add(sid);
        }
      }
    }

    favoriteSongIds.value = ids;
  }

  bool isFavorite(int songId) => favoriteSongIds.value.contains(songId);

  /// Toggle favorite (optimistic UI)
  Future<void> toggleFavorite(int songId) async {
    final current = {...favoriteSongIds.value};
    final wasFav = current.contains(songId);

    // Optimistic update
    if (wasFav) {
      current.remove(songId);
    } else {
      current.add(songId);
    }
    favoriteSongIds.value = current;

    try {
      if (wasFav) {
        // ✅ BE: DELETE /api/favorites/:songId
        await _api.delete('/favorites/$songId');
      } else {
        // ✅ CÁCH B: BE của bạn cần POST /api/favorites/:songId
        await _api.post('/favorites/$songId', {});
      }
    } catch (e) {
      // Rollback nếu fail
      final rollback = {...favoriteSongIds.value};
      if (wasFav) {
        rollback.add(songId);
      } else {
        rollback.remove(songId);
      }
      favoriteSongIds.value = rollback;
      rethrow;
    }
  }
}
