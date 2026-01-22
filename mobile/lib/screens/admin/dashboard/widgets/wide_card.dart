import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class StatWideCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final int value;
  final double percent;
  final IconData icon;
  final Color color;

  const StatWideCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.percent,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isNegative = percent < 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w600)),
                Text(subtitle,
                    style:
                    const TextStyle(fontSize: 13, color: Colors.grey)),
                const SizedBox(height: 12),
                TweenAnimationBuilder<double>( //animation
                  tween: Tween(begin: 0, end: value.toDouble()),
                  duration: const Duration(milliseconds: 1200),
                  builder: (_, val, __) {
                    return Text(
                      _format(val.toInt()),
                      style: const TextStyle(
                          fontSize: 28, fontWeight: FontWeight.bold),
                    );
                  },
                ),
                Row(
                  children: [
                    Icon(
                      isNegative
                          ? Icons.arrow_downward
                          : Icons.arrow_upward,
                      size: 16,
                      color: isNegative ? Colors.red : color,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${percent.abs()}%',
                      style: TextStyle(
                          color: isNegative ? Colors.red : color),
                    ),
                  ],
                )
              ],
            ),
          ),
          Container(
            height: 56,
            width: 56,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Icon(icon, color: color),
          ),
        ],
      ),
    );
  }

  String _format(int value) {
    if (value >= 1000) return '${(value / 1000).toStringAsFixed(1)}k';
    return value.toString();
  }
}
