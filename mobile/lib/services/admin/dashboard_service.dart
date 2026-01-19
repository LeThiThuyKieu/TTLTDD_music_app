import 'package:flutter/material.dart';
import '../../screens/admin/dashboard/top_song.dart';
import '../api_service.dart';

class DashboardService {
  final ApiService _api = ApiService();

  /// 1️ OVERVIEW (4 CARD)
  Future<Map<String, dynamic>> getOverview() async {
    final res = await _api.get('/admin/dashboard/overview');

    if (res['data'] == null) {
      throw Exception('Overview data not found');
    }

    return res['data'];
  }

  /// 2 WEEKLY PLAYS (LINE CHART)
  Future<Map<String, dynamic>> getWeekly() async {
    final res = await _api.get('/admin/dashboard/weekly');

    if (res['data'] == null) {
      throw Exception('Weekly data not found');
    }

    return res['data'];
  }

  /// 3 HIGHLIGHTS
  Future<List<Map<String, dynamic>>> getHighlights() async {
    final res = await _api.get('/admin/dashboard/highlights');

    debugPrint('Highlights: $res');

    if (res['data'] is! List) {
      throw Exception('Invalid highlights format');
    }

    return List<Map<String, dynamic>>.from(res['data']);
  }

  /// 4 TOP SONGS (CHART + LIST)
  Future<List<TopSong>> getTopSongs({int limit = 10}) async {
    final res = await _api.get(
      '/admin/dashboard/topsongs?limit=$limit',
    );

    if (res['data'] is! List) {
      throw Exception('Invalid top songs format');
    }

    final List list = res['data'];

    return list.map((e) => TopSong.fromJson(e)).toList();
  }

  /// 5 GENRE DISTRIBUTION
  Future<List<Map<String, dynamic>>> getGenreDistribution() async {
    final res = await _api.get('/admin/dashboard/genredistribution');

    if (res['data'] is! List) {
      throw Exception('Invalid genre distribution format');
    }

    return List<Map<String, dynamic>>.from(res['data']);
  }
}
