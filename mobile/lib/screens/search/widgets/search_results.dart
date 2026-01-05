import 'package:flutter/material.dart';

import '../../../models/song_model.dart';
import '../../../models/artist_model.dart';
import '../../../models/album_model.dart';
import '../../../models/genre_model.dart';
import 'item/song_item.dart';
import 'item/artist_item.dart';
import 'item/album_item.dart';
import 'item/genre_item.dart';


class SearchResultsWidget extends StatelessWidget {
  final TabController tabController;
  final List<SongModel> songs;
  final List<ArtistModel> artists;
  final List<AlbumModel> albums;
  final List<GenreModel> genres;

  const SearchResultsWidget({
    Key? key,
    required this.tabController,
    required this.songs,
    required this.artists,
    required this.albums,
    required this.genres,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TabBar(
          controller: tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
      padding: EdgeInsets.only(left:20),
          indicator: BoxDecoration(
            color: Color(0xFF1DB954),
            borderRadius: BorderRadius.circular(20),
          ),
          indicatorSize:  TabBarIndicatorSize.tab,
          labelColor: Colors.white,unselectedLabelColor: Colors.green,
          indicatorPadding: const EdgeInsets.symmetric(horizontal: 1, vertical: 7),
          dividerColor: Colors.transparent,
          tabs: const [
            Tab(text: 'Top'),
            Tab(text: 'Bài hát'),
            Tab(text: 'Nghệ sĩ'),
            Tab(text: 'Album'),
            Tab(text: 'Thể loại'),
          ],
        ),
        // Content
        Expanded(
          child: TabBarView(
            controller: tabController,
            children: [
              // TOP
              _buildTopTab(),
              // ListView(
              //   children:
              //   songs.take(5).map((s) => SongItemWidget(song: s)).toList(),
              // ),
              // SONG
              songs.isEmpty
                  ? const Center(child: Text('No songs'))
              :ListView(
                children:
                songs.map((s) => SongItemWidget(song: s)).toList(),
              ),
              /// ARTISTS
              artists.isEmpty
                  ? const Center(child: Text('No artists'))
              :ListView(
                children:
                artists.map((a) => ArtistItemWidget(artist: a)).toList(),
              ),
              /// ALBUMS
              albums.isEmpty
                  ? const Center(child: Text('No albums'))
              :ListView(
                children:
                albums.map((al) => AlbumItemWidget(album: al)).toList(),
              ),
              /// GENRES
              genres.isEmpty
                  ? const Center(child: Text('No genres'))
                  :ListView(
                children:
                genres.map((g) => GenreItemWidget(genre: g, selected: false, onTap: (){},),).toList(),
              ),
              // const Center(child: Text('coming soon')),
            ],
          ),
        ),
      ],
    );
  }
  ///TAB TOP
  Widget _buildTopTab() {
    return ListView(
      children: [
        if (songs.isNotEmpty) ...[
          _sectionTitle('Bài hát'),
          ...songs.take(3).map((s) => SongItemWidget(song: s)),
        ],

        if (artists.isNotEmpty) ...[
          _sectionTitle('Nghệ sĩ'),
          ...artists.take(2).map((a) => ArtistItemWidget(artist: a)),
        ],

        if (albums.isNotEmpty) ...[
          _sectionTitle('Albums'),
          ...albums.take(2).map((a) => AlbumItemWidget(album: a)),
        ],

        if (songs.isEmpty && artists.isEmpty && albums.isEmpty)
          const Padding(
            padding: EdgeInsets.only(top: 40),
            child: Center(child: Text('Không tìm thấy')),
          ),
      ],
    );
  }

  ///SECTION TITLE
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
class _PillTab extends StatelessWidget {
  final String text;
  const _PillTab({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

