import 'package:flutter/material.dart';
import '../../../../models/album_model.dart';

class AlbumItemWidget extends StatelessWidget {
  final AlbumModel album;
  final VoidCallback? onTap;

  const AlbumItemWidget({
    Key? key,
    required this.album,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final year = album.releaseDate?.year;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          children: [
            /// ===== COVER =====
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: album.coverUrl != null
                  ? Image.network(
                album.coverUrl!,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
              )
                  : Container(
                width: 56,
                height: 56,
                color: Colors.grey.shade300,
                child: const Icon(Icons.album, color: Colors.white),
              ),
            ),

            const SizedBox(width: 12),

            /// ===== INFO =====
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  /// Title
                  Text(
                    album.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),

                  /// Subtitle: Album · 2020 · Artist
                  Text(
                    [
                      'Album',
                      if (year != null) year.toString(),
                      if (album.artist != null) album.artist!.name,
                    ].join(' · '),
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
