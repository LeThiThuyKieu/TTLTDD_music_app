import 'package:flutter/material.dart';

class StatusFilter extends StatelessWidget {
  final String value;
  final ValueChanged<String> onChanged;

  const StatusFilter({
    Key? key,
    required this.value,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 44,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.black12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          items: const [
            DropdownMenuItem(
              value: 'Tất cả',
              child: Text('Tất cả'),
            ),
            DropdownMenuItem(
              value: 'Active',
              child: Text('Active'),
            ),
            DropdownMenuItem(
              value: 'Unactive',
              child: Text('Unactive'),
            ),
          ],
          onChanged: (val) {
            if (val != null) {
              onChanged(val);
            }
          },
        ),
      ),
    );
  }
}
