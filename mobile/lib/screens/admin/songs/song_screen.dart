import 'package:flutter/material.dart';
import 'package:music_app/models/song_model.dart';
import '../admin_widgets/input_box.dart';
import '../admin_widgets/status_filter.dart';
import '../../../services/admin/admin_song_service.dart';
import './add_song_screen.dart';
import './update_song_screen.dart';
class AdminSongScreen extends StatefulWidget {
  const AdminSongScreen({Key? key}) : super(key: key);

  @override
  State<AdminSongScreen> createState() => _SongScreenState();
}
// LOGIC
class _SongScreenState extends State<AdminSongScreen> {
  //  Các biến
  final SongService _songService = SongService(); //service gọi API
  List<SongModel> allSongs = []; // ds bài hát từ service
  String selectedStatus = 'Tất cả';
  String searchText = '';
  bool isLoading = false; //loading API
  int limit = 10;
  int currentPage = 1;
  int totalItems = 0;
  int get totalPages => (totalItems / limit).ceil();



  @override
  void initState() {
    super.initState();
    _loadSongs();
  }
  // Load danh sách
  Future<void> _loadSongs({int page = 1}) async {
    try {
      setState(() { isLoading = true;  currentPage = page;} );
      // Gọi API
      final result = await _songService.getAllSongs(
        limit: limit,
        offset: (page - 1) * limit,
      );
      //   Update UI
      setState(() {
        allSongs = result.songs;
        totalItems = result.total;
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
      ScaffoldMessenger.of(context).showSnackBar( //Hiển thị thông báo.
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

  // Widget phân trang
  Widget _buildPagination() {
    return Column(
      children: [
        Text(
          'Showing ${(currentPage - 1) * limit + 1} '
              'to ${((currentPage * limit) > totalItems ? totalItems : currentPage * limit)} '
              'of $totalItems entries',
          style: const TextStyle(fontSize: 12),
        ),
        const SizedBox(height: 8),

        Row(
          //căn chỉnh các widget con theo trục chính
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _pageButton('<<', currentPage > 1
                ? () => _loadSongs(page: 1)
                : null),

            _pageButton('<', currentPage > 1
                ? () => _loadSongs(page: currentPage - 1)
                : null),

            // ...List.generate(
            //   totalPages,
            //       (index) {
            //     final page = index + 1;
            //     return _pageNumber(page);
            //   },
            // ),

            _pageButton('>', currentPage < totalPages
                ? () => _loadSongs(page: currentPage + 1)
                : null),

            _pageButton('>>', currentPage < totalPages
                ? () => _loadSongs(page: totalPages)
                : null),
          ],
        ),
      ],
    );
  }
// BUTTON phân trang
  Widget _pageButton(String text, VoidCallback? onTap) {
    return IconButton(
      icon: Text(text),
      onPressed: onTap, // hàm được truyền từ bên ngoài Sẽ chạy khi bấm nút
    );
  }

  Widget _pageNumber(int page) {
    final isActive = page == currentPage;

    return GestureDetector( //widget bắt sự kiện chạm
      onTap: () => _loadSongs(page: page), //Khi xảy ra sự kiện tap → chạy _loadSongs(...).
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4), // đối xứng
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isActive ? const Color(0xFF8DB27C) : Colors.transparent,
          shape: BoxShape.circle,
        ),
        child: Text(
          '$page',
          style: TextStyle(
            color: isActive ? Colors.white : Colors.black,
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      child: Column(
        // trục dọc
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// PAGE NAME
          Row(
            // trục ngang
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bài hát',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3930)),
              ),
              FloatingActionButton(
                mini: true, //Làm cho nút nhỏ hơn bình thường
                backgroundColor: const Color(0xFF8DB27C),
                onPressed: () async{
                  // Mở screen thêm bài hát (đẩy  màn hình theem mới lên trên
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
                  mainAxisAlignment: MainAxisAlignment.center, // căn chỉnh theo trục dọc
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
                  onChanged: (value) { //callback được gọi mỗi khi nội dung ô nhập thay đổi
                    setState(() { //State đã thay đổi → rebuild UI
                      searchText = value; //Lưu text tìm kiếm vào biến state
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
                    //Truyền hàm xoá từ cha xuống con
                    onDelete: () async => _deleteSong(song),
                        // Callback khi update bài hát thành công
                        onUpdated: () => _loadSongs(page: currentPage),
                  ),
                ),
                const SizedBox(height: 16),
                _buildPagination(),
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
  final VoidCallback onUpdated;

  const _SongItem({
    required this.song,
    required this.onDelete,
    required this.onUpdated,
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
            child: Image.network( //Ảnh từ server
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
              fontSize: 10,
              color: active ? Colors.green : Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          // ACTION BUTTONS
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // EDIT
              IconButton(
              iconSize: 18,
                icon: const Icon(Icons.edit, color: Colors.blueGrey),
                onPressed: () async {
                  final updated = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AdminUpdateSongScreen(songId: song.songId!,),
                    ),
                  );

                  // nếu update thành công → reload list
                  if (updated == true && context.mounted) {
                    onUpdated();
                  }
                },
              ),

              // DELETE
              IconButton(
                icon:
                const Icon(Icons.delete_outline, color: Color(0xFF8DB27C)),
                onPressed: () => _showDeleteDialog(context, song),
              ),
            ],
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
