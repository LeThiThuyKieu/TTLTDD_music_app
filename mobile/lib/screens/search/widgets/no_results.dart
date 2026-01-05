import 'package:flutter/material.dart';

class NoResultsWidget extends StatelessWidget {
  const NoResultsWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'No results found',
        style: TextStyle(fontSize: 22, color: Colors.grey),
      ),
    );
  }
}
