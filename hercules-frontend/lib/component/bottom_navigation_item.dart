import 'package:flutter/material.dart';
import 'package:hercules/location_page.dart';

class BottomNavigationItem extends StatelessWidget {
  final VoidCallback onPressed;
  final IconData icon; // FIX: Change type from String to IconData
  final Menus current;
  final Menus name;

  const BottomNavigationItem({
    super.key,
    required this.onPressed,
    required this.icon, // Fix applied here
    required this.current,
    required this.name,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon, // Use the passed icon dynamically
        color: current == name ? Colors.black : Colors.black.withOpacity(0.3),
      ),
    );
  }
}
