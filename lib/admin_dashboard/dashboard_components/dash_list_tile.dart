import 'package:flutter/material.dart';

class DashListTile extends StatelessWidget {
  final IconData icon;
  final String text;
  final void Function()? onTap; // change as you needed
  const DashListTile({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap, // change as you needed
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10.0),
      child: ListTile(
        leading: Icon(
          icon,
          color: Colors.white,
        ),
        onTap: onTap,
        title: Text(
          text,
          style: TextStyle(color: Colors.white),
          ),
      ),
    );
  }
}