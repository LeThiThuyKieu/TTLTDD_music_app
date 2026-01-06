import 'package:flutter/material.dart';

import '../../../models/album_model.dart';
import '../admin_widgets/input_box.dart';
import '../admin_widgets/status_filter.dart';

class AdminAlbumScreen extends StatefulWidget {
  const AdminAlbumScreen({Key? key}) : super(key: key);

  @override
  State<AdminAlbumScreen> createState() => AlbumScreenState();
}

class AlbumScreenState extends State<AdminAlbumScreen> {
  List<AlbumModel> allAlbums = [];
  String selectedStatus = 'Tất cả';
  String searchText = '';

  @override
  void initState() {
    super.initState();
    _loadMockData(); // 👉 sau thay bằng API
  }

  void _loadMockData() {
    allAlbums = [
      AlbumModel(
        albumId: 1,
        title: 'Chúng Ta',
        coverUrl:
        'https://is1-ssl.mzstatic.com/image/thumb/Video211/v4/f0/66/61/f066611b-7c43-9828-389a-eb6eb5e12baa/Job84b233bc-78a8-4f70-b490-364be97d41ab-167536029-PreviewImage_Preview_Image_Intermediate_nonvideo_sdr_325854773_1760978097-Time1715042749638.png/316x316bb.webp',
        isActive: 1,
      ),
      AlbumModel(
        albumId: 2,
        title: 'Tâm 9',
        coverUrl:
        'https://i.scdn.co/image/ab67616d0000b2734454611710af2f8df7f2fbfe',
        isActive: 1,
      ),
      AlbumModel(
        albumId: 3,
        title: 'Veston',
        coverUrl:
        'https://i1.sndcdn.com/artworks-000457791939-wrwc65-t500x500.jpg',
        isActive: 0,
      ),
    ];
  }
  //  search +filter
  List<AlbumModel> get filteredAlbums {
    return allAlbums.where((album) {
      final matchSearch = album.title
          .toLowerCase()
          .contains(searchText.toLowerCase());

      final matchStatus =
          selectedStatus == 'Tất cả' ||
              (selectedStatus == 'Active' && album.isActive == 1) ||
              (selectedStatus == 'Unactive' && album.isActive == 0);

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
                'Album',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3930)),
              ),
              FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF8DB27C),
                onPressed: () {},
                child: const Icon(Icons.add, color: Colors.white,),
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
                    Icon(Icons.album, size: 30),
                    SizedBox(width: 8),
                    Text(
                      'Danh sách các Album',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// SEARCH
                InputBox(
                  icon: Icons.search,
                  hint: 'Tìm kiếm album...',
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
                ...filteredAlbums.map(
                      (album) => AlbumItem(
                    album: album,
                    onDelete: () {
                      setState(() {
                        allAlbums.remove(album);
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

/// ================= ALBUM ITEM =================
class AlbumItem extends StatelessWidget {
  final AlbumModel album;
  final VoidCallback onDelete;

  const AlbumItem({
    required this.album,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final active = album.isActive == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(2),
            child: Image.network(
              album.coverUrl ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade300,
                child: const Icon(Icons.album),
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
                  album.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
                // Text(
                //   album.artistNames,
                //   style: const TextStyle(
                //     fontSize: 12,
                //     color: Colors.black54,
                //   ),
                // ),
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
        backgroundColor: Colors.white,
        title: const Text('Xoá Album'),
        content: Text('Bạn có chắc muốn xoá "${album.title}" không?'),
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
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
