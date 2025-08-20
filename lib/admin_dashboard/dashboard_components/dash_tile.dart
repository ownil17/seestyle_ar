import 'package:flutter/material.dart';

class DashTile extends StatelessWidget {
  const DashTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
          color: Colors.grey[400],
          borderRadius: BorderRadius.circular(12), // <-- round the corners
        ),
      ),
    );
  }
}