import 'package:flutter/material.dart';

class MyBomb extends StatelessWidget {
  final bool revealed;
  final bool flagged;
  final String imagePath; // Pre-assigned image
  final VoidCallback? function;
  final VoidCallback? onLongPress;

  const MyBomb({
    super.key,
    required this.revealed,
    required this.flagged,
    required this.imagePath,
    this.function,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: function,
      onLongPress: onLongPress,
      child: Container(
        decoration: BoxDecoration(
          color: revealed ? Colors.grey[800] : Colors.grey[400],
          border: Border.all(color: Colors.grey[600]!, width: 1),
        ),
        child: Center(
          child:
              revealed
                  ? Image.asset(imagePath, width: 20, height: 20)
                  : flagged
                  ? const Icon(Icons.close, color: Colors.red, size: 20)
                  : null,
        ),
      ),
    );
  }
}
