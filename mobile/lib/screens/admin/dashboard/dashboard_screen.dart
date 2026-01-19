import 'package:flutter/material.dart';
import 'package:music_app/screens/admin/dashboard/widgets/genre_chart.dart';
import 'package:music_app/screens/admin/dashboard/widgets/horizontal_stat_card.dart';
import 'package:music_app/screens/admin/dashboard/widgets/top_song_chart.dart';
import 'package:music_app/screens/admin/dashboard/widgets/top_song_list.dart';
import 'package:music_app/screens/admin/dashboard/widgets/weekly_plays_chart.dart';
import 'package:music_app/screens/admin/dashboard/widgets/wide_card.dart';
import './top_song.dart';
import '../../../services/admin/dashboard_service.dart';

class MusicDashboardPage extends StatelessWidget {
  MusicDashboardPage({super.key});
  final DashboardService _dashboardService = DashboardService();

  //API 1: GET api/admin/dashboard/overview
  Widget _buildOverview() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardService.getOverview(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Không thể tải overview: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final data = snapshot.data!;

        double calcPercent(int active, int total) {
          if (total == 0) return 0;
          return active / total;
        }

        return Column(
          children: [
            /// ROW 1
            Row(
              children: [
                Expanded(
                  child: HorizontalStatCard(
                    title: 'Bài hát',
                    total: data['songs']['total'],
                    percent: calcPercent(
                      data['songs']['active'],
                      data['songs']['total'],
                    ),
                    color: Colors.green,
                    statusText: 'Active',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HorizontalStatCard(
                    title: 'Album',
                    total: data['albums']['total'],
                    percent: calcPercent(
                      data['albums']['active'],
                      data['albums']['total'],
                    ),
                    color: Colors.pink,
                    statusText: 'Active',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            /// ROW 2
            Row(
              children: [
                Expanded(
                  child: HorizontalStatCard(
                    title: 'Nghệ sĩ',
                    total: data['artists']['total'],
                    percent: calcPercent(
                      data['artists']['active'],
                      data['artists']['total'],
                    ),
                    color: Colors.blue,
                    statusText: 'Available',
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: HorizontalStatCard(
                    title: 'Người dùng',
                    total: data['users']['total'],
                    percent: calcPercent(
                      data['users']['active'],
                      data['users']['total'],
                    ),
                    color: Colors.orange,
                    statusText: 'Online',
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
  // API 2: (GET admin/dashboard/weekly)
  Widget _buildWeeklyChart() {
    return FutureBuilder<Map<String, dynamic>>(
      future: _dashboardService.getWeekly(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const CircularProgressIndicator();
        }
        final data = snapshot.data!;
        return WeeklyPlaysChart(
          total: data['total'],
          daily: List<Map<String, dynamic>>.from(data['daily']),
        );
      },
    );
  }

  //3
  final List<IconData> highlightIcons = const [
    Icons.headphones,
    Icons.favorite,
    Icons.queue_music,
  ];

  final List<Color> highlightColors = const [
    Colors.green,
    Colors.pink,
    Colors.blue,
  ];
  // API 3: Get api/admin/dashboard/hightlights
  Widget _buildHighlights() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dashboardService.getHighlights(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Không thể tải highlights: ${snapshot.error}',
              style: const TextStyle(color: Colors.red),
            ),
          );
        }

        final data = snapshot.data!;

        return Column(
          children: List.generate(data.length, (index) {
            final item = data[index];

            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: StatWideCard(
                title: item['title'],
                subtitle: item['subtitle'] ?? '',
                value: item['value'],
                percent: (item['percent'] as num).toDouble(),
                icon: highlightIcons[index],
                color: highlightColors[index],
              ),
            );
          }),
        );
      },
    );
  }
  // API 4 (GET api/admin/dashboard/topsongs?limit=10)
  Widget _buildTopSongs() {
    return FutureBuilder<List<TopSong>>(
      future: _dashboardService.getTopSongs(limit: 10),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Không thể tải top songs: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final songs = snapshot.data!;

        return TopSongsList(songs: songs);
      },
    );
  }
// API 5: (GET: api/admin/dashboard/genredistribution)
  Widget _buildGenreDistribution() {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _dashboardService.getGenreDistribution(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Text(
            'Không thể tải genre: ${snapshot.error}',
            style: const TextStyle(color: Colors.red),
          );
        }

        final data = snapshot.data!;

        final colors = [
          const Color(0xFFD8F05E),
          const Color(0xFFAFC8A1),
          const Color(0xFF9BB87D),
          const Color(0xFF7FA567),
          const Color(0xFF5E8C4E),
        ];

        final genres = List.generate(data.length, (index) {
          return GenreStat(
            name: data[index]['name'],
            songCount: data[index]['songCount'],
            color: colors[index % colors.length],
          );
        });

        return GenreDistributionCard(genres: genres);
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6F7F3),
      appBar: AppBar(
        title: const Text('Dashboard',
        style:  TextStyle(fontSize: 22, fontWeight: FontWeight.w700,
          color: Color(0xFF2C3930),),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 1. Overview
            _buildOverview(),
            const SizedBox(height: 20),

            /// 2CHARTS weekly
            _buildWeeklyChart(),
            const SizedBox(height: 20),

            // 3.hightlight
            _buildHighlights(),

            // const SizedBox(height: 20),
            // TopSongsChart(songs: topSongs),

            const SizedBox(height: 20),
            _buildTopSongs(),

            const SizedBox(height: 20),
            _buildGenreDistribution(),
          ],
        ),
      ),
    );
  }
}