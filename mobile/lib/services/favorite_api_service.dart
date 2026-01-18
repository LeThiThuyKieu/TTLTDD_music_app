import 'package:flutter/foundation.dart';
import 'api_service.dart';

class FavoriteApiService {
  FavoriteApiService._();
  static final FavoriteApiService instance = FavoriteApiService._();

  final ApiService _api = ApiService();

  /// Cache danh sách songId đã yêu thích
  final ValueNotifier<Set<int>> favoriteSongIds =
  ValueNotifier<Set<int>>(<int>{});

  /// ===============================
  /// LOAD FAVORITES TỪ SERVER
  /// ===============================
  Future<void> loadFavorites() async {
    final res = await _api.get('/favorites');

    // Backend có thể trả:
    // { data: [...] } hoặc [...]
    final rawData = res['data'] ?? res;

    final Set<int> ids = <int>{};

    if (rawData is List) {
      for (final item in rawData) {
        if (item is int) {
          ids.add(item);
        } else if (item is Map) {
          final rawId =
              item['song_id'] ?? item['songId'] ?? item['id'];
          final songId = int.tryParse(rawId?.toString() ?? '');
          if (songId != null) {
            ids.add(songId);
          }
        }
      }
    }

    favoriteSongIds.value = ids;
  }

  /// ===============================
  /// CHECK FAVORITE
  /// ===============================
  bool isFavorite(int songId) {
    return favoriteSongIds.value.contains(songId);
  }

  /// ===============================
  /// TOGGLE FAVORITE (OPTIMISTIC UI)
  /// ===============================
  Future<void> toggleFavorite(int songId) async {
    final previous = favoriteSongIds.value;
    final updated = {...previous};

    final bool wasFavorite = previous.contains(songId);

    // 1️⃣ Optimistic update (UI đổi ngay)
    if (wasFavorite) {
      updated.remove(songId);
    } else {
      updated.add(songId);
    }
    favoriteSongIds.value = updated;

    try {
      // 2️⃣ Gọi API
      if (wasFavorite) {
        // DELETE /favorites/:songId
        await _api.delete('/favorites/$songId');
      } else {
        // POST /favorites/:songId
        await _api.post('/favorites/$songId', {});
      }
    } catch (e) {
      // 3️⃣ Rollback nếu lỗi
      favoriteSongIds.value = previous;
      rethrow;
    }
  }
}
