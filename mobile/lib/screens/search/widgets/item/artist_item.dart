import 'package:flutter/material.dart';
import '../../../../models/artist_model.dart';

class ArtistItemWidget extends StatelessWidget {
  final ArtistModel artist;
  final VoidCallback? onFollow;
  final VoidCallback? onTap;

  const ArtistItemWidget({
    Key? key,
    required this.artist,
    this.onFollow,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            /// ===== AVATAR =====
            CircleAvatar(
              radius: 26,
              backgroundImage: artist.avatarUrl != null
                  ? NetworkImage(artist.avatarUrl!)
                  : null,
              backgroundColor: Colors.grey.shade300,
              child: artist.avatarUrl == null
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),

            const SizedBox(width: 12),

            /// ===== NAME + TYPE =====
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
                  const SizedBox(height: 4),
                  Text(
                    'Artist',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),

            /// ===== FOLLOW BUTTON (UI) =====
            ElevatedButton(
              onPressed: onFollow ?? () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1DB954),
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text('Follow'),
            ),
          ],
        ),
      ),
    );
  }
}
