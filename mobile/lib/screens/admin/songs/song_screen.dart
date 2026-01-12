import 'package:flutter/material.dart';
import 'package:music_app/models/song_model.dart';
import '../../../models/artist_model.dart';
import '../admin_widgets/input_box.dart';
import '../admin_widgets/status_filter.dart';
import '../../../services/admin/admin_song_service.dart';
import './add_song_screen.dart';
class AdminSongScreen extends StatefulWidget {
  const AdminSongScreen({Key? key}) : super(key: key);

  @override
  State<AdminSongScreen> createState() => _SongScreenState();
}

class _SongScreenState extends State<AdminSongScreen> {
  final SongService _songService = SongService();
  List<SongModel> allSongs = [];
  String selectedStatus = 'Tất cả';
  String searchText = '';
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadSongs();
  }
  // Load danh sách
  Future<void> _loadSongs() async {
    try {
      setState(() => isLoading = true);

      final songs = await _songService.getAllSongs(); //JSON được fetch ở đây

      setState(() {
        allSongs = songs;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Load songs error: $e');
    }
  }

  // void _loadMockData() {
  //   allSongs = [
  //     SongModel(
  //       songId: 1,
  //       title: 'Chúng Ta Của Hiện Tại',
  //       fileUrl: '',
  //       coverUrl:
  //       'https://i.ytimg.com/vi/ryC6nsOk5l8/maxresdefault.jpg',
  //       isActive: 1,
  //       artists: [
  //         ArtistModel(
  //           artistId: 1,
  //           name: 'Sơn Tùng M-TP',
  //         ),
  //       ],
  //     ),
  //     SongModel(
  //       songId: 2,
  //       title: 'Em Của Ngày Hôm Qua',
  //       fileUrl: '',
  //       coverUrl:
  //       'https://tse4.mm.bing.net/th/id/OIP.IQmKPXq1c4gqBaNLZeCwUgHaHa',
  //       isActive: 1,
  //       artists: [
  //         ArtistModel(
  //           artistId: 1,
  //           name: 'Sơn Tùng M-TP',
  //         ),
  //       ],
  //     ),
  //     SongModel(
  //       songId: 3,
  //       title: 'Nàng Thơ',
  //       fileUrl: '',
  //       coverUrl:
  //       'https://giaitritivi.com/wp-content/uploads/2025/06/loi-bai-hat-nang-tho.webp',
  //       isActive: 0,
  //       artists: [
  //         ArtistModel(
  //           artistId: 2,
  //           name: 'Hoàng Dũng',
  //         ),
  //       ],
  //     ),
  //   ];
  // }
  // Xoá bài hát
  Future<void> _deleteSong(SongModel song) async {
    try {
      await _songService.deleteSong(song.songId!); // gọi API
      setState(() {
        allSongs.remove(song); // xoá khỏi local
      });
      // _loadSongs();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xoá bài hát thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xoá thất bại: $e')),
      );
    }
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
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3930)),
              ),
              FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF8DB27C),
                onPressed: () async{
                  // Mở screen thêm bài hát
                  final added = await Navigator.push(context, MaterialPageRoute(builder: (_) =>
                        AdminAddSongScreen()
                  ),
                  );
                  // Nếu có bài hát mới thêm thành công → fetch lại list
                  if (added == true) {
                    _loadSongs();
                  }
                },
                child: const Icon(Icons.add, color: Colors.white),
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
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.library_music, size: 30),
                    SizedBox(width: 15),
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
                    onDelete: () async => _deleteSong(song),
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
  final Future<void> Function() onDelete;

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
            onPressed: () => _showDeleteDialog(context, song),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, SongModel song) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Xoá bài hát'),
        content: Text('Bạn có chắc muốn xoá "${song.title}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
            Navigator.pop(context); // đóng dialog
            await onDelete(); // chỉ gọi api khi xác nhận
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
