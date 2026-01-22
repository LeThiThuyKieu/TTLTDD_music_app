import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class GenreStat {
  final String name;
  final int songCount;
  final Color color;

  GenreStat({
    required this.name,
    required this.songCount,
    required this.color,
  });
}

class GenreDistributionCard extends StatelessWidget {
  final List<GenreStat> genres;
  const GenreDistributionCard({super.key, required this.genres});
  @override
  Widget build(BuildContext context) {
    final totalSongs = //fold = duyệt list và cộng dồn
    genres.fold<int>(0, (sum, item) => sum + item.songCount);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5EF),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.category, size: 28),
              SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Phân bố thể loại',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    'Số lượng bài hát theo thể loại',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              )
            ],
          ),

          const SizedBox(height: 20),

          /// DONUT CHART
          Center(
            child: SizedBox(
              height: 180,
              width: 180,
              child: CustomPaint(
                painter: DonutChartPainter(genres),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        totalSongs.toString(),
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Bài hát',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 20),

          /// LIST GENRE
          ...genres.map((g) {
            final percent =
            (g.songCount / totalSongs * 100).toStringAsFixed(0);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Row(
                children: [
                  Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: g.color,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(child: Text(g.name)),
                  Text('${g.songCount} bài'),
                  const SizedBox(width: 12),
                  Text(
                    '$percent%',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }
}
class DonutChartPainter extends CustomPainter {
  final List<GenreStat> data;

  DonutChartPainter(this.data);

  @override
  void paint(Canvas canvas, Size size) {
    final total =
    data.fold<int>(0, (sum, item) => sum + item.songCount);
    double startAngle = -1.5708; // -90 độ

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 30
      ..strokeCap = StrokeCap.butt;

    for (final item in data) {
      //tính tỷ lệ phần trăm và quy đổi sang góc quét
      final sweepAngle = (item.songCount / total) * 6.28318;
      paint.color = item.color;
// vẽ cung tròn (arc) tương ứng 1 genre
      canvas.drawArc(
        Rect.fromLTWH(0, 0, size.width, size.height),
        startAngle, //cập nhật startAngle sau mỗi lần vẽ.
        sweepAngle,
        false,
        paint,
      );

      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
