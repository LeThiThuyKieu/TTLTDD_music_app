import 'package:flutter/material.dart';
import 'package:music_app/models/artist_model.dart';
import 'package:music_app/screens/admin/artists/update_artist_screen.dart';
import '../admin_widgets/input_box.dart';
import '../admin_widgets/status_filter.dart';
import '../../../services/admin/admin_artist_service.dart';
import 'add_artist_screen.dart';

class AdminArtistScreen extends StatefulWidget {
  const AdminArtistScreen({Key? key}) : super(key: key);

  @override
  State<AdminArtistScreen> createState() => ArtistScreenState();
}

class ArtistScreenState extends State<AdminArtistScreen> {
  List<ArtistModel> allArtists = [];
  String selectedStatus = 'Tất cả';
  String searchText = '';
  bool isLoading = false;
  final _artistService = ArtistService();

  @override
  void initState() {
    super.initState();
    _loadArtists();
  }
  Future<void> _loadArtists() async {
    try {
      setState(() => isLoading = true);

      final artists = await _artistService.getAllArtists(); //JSON được fetch ở đây

      setState(() {
        allArtists = artists;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      debugPrint('Load artists error: $e');
    }
  }
  // void loadMockData() {
  //   allArtists = [
  //     ArtistModel(
  //       artistId: 1,
  //       name: 'Sơn Tùng M-TP',
  //       avatarUrl: 'https://encrypted-tbn3.gstatic.com/images?q=tbn:ANd9GcS0X52aE766v34_fcodYeawXEtTqtWDo8a_J89nPGplo9SoJj-c',
  //       description: 'Ca sĩ, nhạc sĩ nổi tiếng Việt Nam',
  //       isActive: 1),
  //     ArtistModel(
  //         artistId: 2,
  //         name: 'Mỹ Tâm',
  //         avatarUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRjWEdQsrGaw9U3pYzBiJ7FZaWzvqpJdGJeS54HZ5YxIjG3S9syTLxgln5hSBR8faHrl2ouBFr-7tSZoCuA9U67mxeH-_qREnc_0Wq7wItwBw&s=10',
  //         description: 'Nữ ca sĩ hàng đầu V-pop',
  //         isActive: 1),
  //     ArtistModel(
  //         artistId: 3,
  //         name: 'Wanbi',
  //         avatarUrl: 'https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSf076tYM2G5m6kkNdE5KdANKTeILUzmNOif1VrWGUgnkmNz6nDpVFbjzMyOXgzZi8aOC9q9wafjDVgEx2y2NPGvZznZRdPo2ipIfcjn8wg-Q&s=10',
  //         description: 'ca sĩ tuổi thơ hàng triệu khán giả',
  //         isActive: 0)
  //   ];
  // }

  // Xoá nghệ sĩ
  Future<void> _deleteArtist(ArtistModel artist) async {
    try {
      await _artistService.deleteArtist(artist.artistId!); // gọi API
      setState(() {
        allArtists.remove(artist); // xoá khỏi local
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Xoá nghệ sĩ khỏi danh sách thành công')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Xoá thất bại: $e')),
      );
    }
  }

  //search +filter
  List<ArtistModel> get filteredArtists {
    return allArtists.where((artist) {
      final matchSearch = artist.name
          .toLowerCase()
          .contains(searchText.toLowerCase());

      final matchStatus =
          selectedStatus == 'Tất cả' ||
              (selectedStatus == 'Active'&& artist.isActive ==1) ||
                (selectedStatus == 'Unactive' && artist.isActive ==0);
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
          //PAGE NAME
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text (
                'Nghệ sĩ',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF2C3930)),
              ),
              FloatingActionButton(
                mini: true,
                backgroundColor: const Color(0xFF8DB27C),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminAddArtistScreen(),
                    ),
                  );

                  // Nếu thêm thành công → reload list
                  if (result == true) {
                    _loadArtists();
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
                    Icon(Icons.people, size: 30),
                    SizedBox(width: 15),
                    Text(
                      'Danh sách nghệ sĩ',
                      style:
                      TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                /// SEARCH
                InputBox(
                  icon: Icons.search,
                  hint: 'Tìm kiếm nghệ sĩ...',
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
                ...filteredArtists.map(
                      (artist) => ArtistItem(
                    artist: artist,
                    onDelete: () async => _deleteArtist(artist),
                        onUpdated: _loadArtists,
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
class ArtistItem extends StatelessWidget {
  final ArtistModel artist;
  final Future<void> Function() onDelete;
  final VoidCallback onUpdated;

  const ArtistItem({
    required this.artist,
    required this.onDelete,
    required this.onUpdated,
  });

  @override
  Widget build(BuildContext context) {
    final active = artist.isActive == 1;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          // IMAGE
          ClipRRect(
            borderRadius: BorderRadius.circular(30),
            child: Image.network(
              artist.avatarUrl ?? '',
              width: 50,
              height: 50,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 50,
                height: 50,
                color: Colors.grey.shade300,
                child: const Icon(Icons.people),
              ),
            ),
          ),

          const SizedBox(width: 15),

          /// INFO
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  artist.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 1),
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
          /// ACTION BUTTONS
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
                      builder: (_) =>
                          AdminUpdateArtistScreen(artistId: artist.artistId!),
                    ),
                  );
                  if (updated == true && context.mounted) {
                    onUpdated();
                  }
                },
              ),

              // DELETE
              IconButton(
                icon: const Icon(Icons.delete_outline,
                    color: Color(0xFF8DB27C)),
                onPressed: () => _showDeleteDialog(context, artist),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ArtistModel artist) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: Colors.white,
        title: const Text('Xoá nghệ sĩ'),
        content: Text('Bạn có chắc muốn xoá "${artist.name}" không?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Huỷ'),
          ),
          ElevatedButton(
            style:
            ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () async {
              Navigator.pop(context); // đóng dialog
              await onDelete();  // chỉ gọi api khi xacs nhận xoá
            },
            child: const Text('Xoá', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
