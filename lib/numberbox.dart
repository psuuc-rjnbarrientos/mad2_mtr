import 'package:flutter/material.dart';

class MyNumberBox extends StatelessWidget {
  final int child; // hazardsAround
  final bool revealed;
  final bool flagged;
  final String imagePath; // Pre-assigned image
  final VoidCallback? function;
  final VoidCallback? onLongPress;

  const MyNumberBox({
    super.key,
    required this.child,
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
          color: revealed ? Colors.grey[200] : Colors.grey[400],
          border: Border.all(color: Colors.grey[600]!, width: 1),
        ),
        child: Center(
          child: revealed
              ? child == 0
                  ? Image.asset(
                      imagePath,
                      width: 20,
                      height: 20,
                    )
                  : Text(
                      child.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: child == 1
                            ? Colors.blue
                            : child == 2
                                ? Colors.green
                                : Colors.red,
                      ),
                    )
              : flagged
                  ? const Icon(
                      Icons.close,
                      color: Colors.red,
                      size: 20,
                    )
                  : null,
        ),
      ),
    );
  }
}