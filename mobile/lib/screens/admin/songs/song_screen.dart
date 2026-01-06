import 'package:flutter/material.dart';
import 'package:music_app/models/song_model.dart';
import '../../../models/artist_model.dart';
import '../admin_widgets/input_box.dart';
import '../admin_widgets/status_filter.dart';
import './widgets/song_card.dart';

class SongScreen extends StatefulWidget {
  const SongScreen({Key? key}) : super(key: key);

  @override
  State<SongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<SongScreen> {
  List<SongModel> allSongs = [];
  String selectedStatus = 'Tất cả';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _loadMockData(); // 👉 sau thay bằng API
  }

  void _loadMockData() {
    allSongs = [
      SongModel(
        songId: 1,
        title: 'Chúng Ta Của Hiện Tại',
        fileUrl: '',
        coverUrl:
        'https://i.ytimg.com/vi/ryC6nsOk5l8/maxresdefault.jpg',
        isActive: 1,
        artists: [
          ArtistModel(
            artistId: 1,
            name: 'Sơn Tùng M-TP',
          ),
        ],
      ),
      SongModel(
        songId: 2,
        title: 'Em Của Ngày Hôm Qua',
        fileUrl: '',
        coverUrl:
        'https://tse4.mm.bing.net/th/id/OIP.IQmKPXq1c4gqBaNLZeCwUgHaHa',
        isActive: 1,
        artists: [
          ArtistModel(
            artistId: 1,
            name: 'Sơn Tùng M-TP',
          ),
        ],
      ),
      SongModel(
        songId: 3,
        title: 'Nàng Thơ',
        fileUrl: '',
        coverUrl:
        'https://giaitritivi.com/wp-content/uploads/2025/06/loi-bai-hat-nang-tho.webp',
        isActive: 0,
        artists: [
          ArtistModel(
            artistId: 2,
            name: 'Hoàng Dũng',
          ),
        ],
      ),
    ];
  }
  //  search +filter
  List<SongModel> get filteredSongs {
    return allSongs.where((song) {
      final matchSearch = song.title
          .toLowerCase()
          .contains(searchText.toLowerCase());

      final matchStatus =
          selectedStatus == 'Tất cả' ||
              (selectedStatus == 'Active' && song.isActive == 1) ||
              (selectedStatus == 'Unactive' && song.isActive == 0);

      return matchSearch && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// PAGE NAME
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bài hát',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF8DB27C),
                onPressed: () {},
                child: const Icon(Icons.add),
              ),
            ],
          ),

          const SizedBox(height: 16),

          /// CARD
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F6F1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // TIÊU ĐỀ
              children: [
                const Row(
                  children: [
                    Icon(Icons.library_music, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Danh sách bài hát',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// SEARCH
                InputBox(
                  icon: Icons.search,
                  hint: 'Tìm kiếm bài hát...',
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                ),

                const SizedBox(height: 12),

                /// FILTER
                StatusFilter(
                  value: selectedStatus,
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value;
                    });
                  },
                ),

                const SizedBox(height: 16),

                /// LIST
                ...filteredSongs.map(
                      (song) => _SongItem(
                    song: song,
                    onDelete: () {
                      setState(() {
                        allSongs.remove(song);
                      });
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// ================= SONG ITEM =================
class _SongItem extends StatelessWidget {
  final SongModel song;
  final VoidCallback onDelete;

  const _SongItem({
    required this.song,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final active = song.isActive == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.network(
              song.coverUrl ?? '',
              width: 44,
              height: 44,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 44,
                height: 44,
                color: Colors.grey.shade300,
                child: const Icon(Icons.music_note),
              ),
            ),
          ),

          const SizedBox(width: 12),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  song.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  song.artistNames,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
            //TEXT STATUS
          Text(
            active ? 'Active' : 'Unactive',
            style: TextStyle(
              fontSize: 12,
              color: active ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          // ICON XOÁ
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Color(0xFF8DB27C)),
            onPressed: () => _showDeleteDialog(context),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Xoá bài hát'),
        content: Text('Bạn có chắc muốn xoá "${song.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () {
              Navigator.pop(context);
              onDelete();
            },
            child: const Text('Xoá'),
          ),
        ],
      ),
    );
  }
}
