import 'package:flutter/material.dart';

class RecentSearchesWidget extends StatelessWidget {
  final List<String> recentSearches;
  final VoidCallback onClearAll;
  final Function(String) onItemTap;
  final Function(String) onDeleteItem;

  const RecentSearchesWidget({
    Key? key,
    required this.recentSearches,
    required this.onClearAll,
    required this.onItemTap,
    required this.onDeleteItem,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Nội dung tìm kiếm gần đây',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            TextButton(onPressed: onClearAll, child: const Text('Xoá tất cả')),
          ],
        ),
        Expanded(
          child: ListView.builder(
            itemCount: recentSearches.length,
            itemBuilder: (_, i) {
              final item = recentSearches[i];
              return ListTile(
                title: Text(item),
                leading: const Icon(Icons.history),
                trailing: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => onDeleteItem(item),
                ),
                onTap: () => onItemTap(item),
              );
            },
          ),
        ),
      ],
    );
  }
}
