import 'package:flutter/material.dart';

class BrowseCategoriesWidget extends StatelessWidget {
  const BrowseCategoriesWidget({Key? key}) : super(key: key);

  static const categories = [
    {'title': 'Pop', 'color': Colors.pink},
    {'title': 'Rock', 'color': Colors.teal},
    {'title': 'Hip-Hop', 'color': Colors.brown},
    {'title': 'Jazz', 'color': Colors.blue},
    {'title': 'Pop', 'color': Colors.green},
    {'title': 'Rock', 'color': Colors.yellow},
    {'title': 'Hip-Hop', 'color': Colors.blue},
    {'title': 'Jazz', 'color': Colors.grey},
  ];

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.6,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: categories.length,
      itemBuilder: (_, i) {
        final cat = categories[i];
        return Container(
          decoration: BoxDecoration(
            color: cat['color'] as Color,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              cat['title'] as String,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
          ),
        );
      },
    );
  }
}
