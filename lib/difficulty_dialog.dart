import 'package:flutter/material.dart';
import 'package:mad2_mtr/homepage.dart';

class DifficultyDialog extends StatelessWidget {
  const DifficultyDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.grey[700],
      title: const Text(
        'Difficulty',
        style: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          DifficultyButton(
            level: 'Easy',
            color: Colors.green,
            onTap: () => _startGame(context, 'Easy'),
          ),
          const SizedBox(height: 10),
          DifficultyButton(
            level: 'Medium',
            color: Colors.orange,
            onTap: () => _startGame(context, 'Medium'),
          ),
          const SizedBox(height: 10),
          DifficultyButton(
            level: 'Hard',
            color: Colors.red,
            onTap: () => _startGame(context, 'Hard'),
          ),
        ],
      ),
    );
  }

  void _startGame(BuildContext context, String difficulty) {
    Navigator.pop(context);
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => HomePage(difficulty: difficulty)),
    );
  }
}

class DifficultyButton extends StatelessWidget {
  final String level;
  final Color color;
  final VoidCallback onTap;

  const DifficultyButton({
    super.key,
    required this.level,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onTap,
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
        fixedSize: const Size(200, 60),
      ),
      child: Text(
        level,
        style: const TextStyle(
          fontSize: 20,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
