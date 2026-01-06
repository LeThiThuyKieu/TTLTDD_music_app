import 'package:flutter/material.dart';
import '../../models/artist_model.dart';

class ArtistListScreen extends StatelessWidget {
  final List<ArtistModel> artists;

  const ArtistListScreen({
    super.key,
    required this.artists,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // ===== APP BAR =====
      appBar: AppBar(
        title: const Text('Nghệ sĩ'),
        centerTitle: false,
      ),

      // ===== DANH SÁCH NGHỆ SĨ =====
      body: ListView.builder(
        itemCount: artists.length,
        itemBuilder: (context, index) {
          final artist = artists[index];

          return ListTile(
            leading: CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey.shade300,
              backgroundImage:
              artist.avatarUrl != null && artist.avatarUrl!.isNotEmpty
                  ? NetworkImage(artist.avatarUrl!)
                  : null,
              child: (artist.avatarUrl == null ||
                  artist.avatarUrl!.isEmpty)
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(
              artist.name,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              // TODO: mở artist detail sau này
              debugPrint('Open artist: ${artist.name}');
            },
          );
        },
      ),
    );
  }
}
