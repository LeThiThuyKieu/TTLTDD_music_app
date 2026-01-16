import 'package:flutter/material.dart';

class WeeklyPlaysChart extends StatelessWidget {
  final List<Map<String, dynamic>> daily;
  final int total;

  const WeeklyPlaysChart({
    super.key,
    required this.daily,
    required this.total,
  });

  @override
  Widget build(BuildContext context) {
    final plays = daily.map((e) => e['value'] as int).toList();
    final days = daily.map((e) {
      final d = DateTime.parse(e['date']);
      return '${d.day}/${d.month}';
    }).toList();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFE8EED9),
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tổng lượt nghe',
                      style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                     ),),
          const SizedBox(height: 6),
          Text(
            total.toString(),
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          /// SMOOTH AREA CHART
          SizedBox(
            height: 140,
            width: double.infinity,
            child: CustomPaint(
              painter: SmoothAreaChartPainter(plays),
            ),
          ),

          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: days
                .map((d) => Text(
              d,
              style:
              TextStyle(fontSize: 12, color: Colors.black54),
            ))
                .toList(),
          ),
        ],
      ),
    );
  }
}

/// ================= SMOOTH BEZIER PAINTER =================
class SmoothAreaChartPainter extends CustomPainter {
  final List<int> values;

  SmoothAreaChartPainter(this.values);

  @override
  void paint(Canvas canvas, Size size) {
    final maxValue =
    values.reduce((a, b) => a > b ? a : b).toDouble();
    final stepX = size.width / (values.length - 1);

    final points = <Offset>[];

    for (int i = 0; i < values.length; i++) {
      final x = stepX * i;
      final y =
          size.height - (values[i] / maxValue) * size.height;
      points.add(Offset(x, y));
    }

    final linePaint = Paint()
      ..color = Colors.green.shade700
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    final areaPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.green.withOpacity(0.25);

    final linePath = Path();
    final areaPath = Path();

    linePath.moveTo(points.first.dx, points.first.dy);
    areaPath.moveTo(points.first.dx, points.first.dy);

    for (int i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];

      final controlPoint1 =
      Offset((p0.dx + p1.dx) / 2, p0.dy);
      final controlPoint2 =
      Offset((p0.dx + p1.dx) / 2, p1.dy);

      linePath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );

      areaPath.cubicTo(
        controlPoint1.dx,
        controlPoint1.dy,
        controlPoint2.dx,
        controlPoint2.dy,
        p1.dx,
        p1.dy,
      );
    }

    /// Close area
    areaPath
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(areaPath, areaPaint);
    canvas.drawPath(linePath, linePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
