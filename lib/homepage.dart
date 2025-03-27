import 'dart:async';
import 'dart:math';
import 'dart:collection';
import 'package:flutter/material.dart';
import 'package:mad2_mtr/bomb.dart';
import 'package:mad2_mtr/main.dart';
import 'package:mad2_mtr/numberbox.dart';

class HomePage extends StatefulWidget {
  final String difficulty;
  const HomePage({super.key, required this.difficulty});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int numberOfSquares;
  late int numberInEachRow;
  var squareStatus = []; // [hazardsAround, revealed, flagged, imagePath]
  List<int> hazardLocation = [];
  bool hazardsRevealed = false;
  int elapsedTime = 0;
  Timer? timer;

  static final List<String> freshGoods = [
    'assets/images/fresh_tomato.png',
    'assets/images/fresh_fish.png',
    'assets/images/fresh_kangkong.png',
  ];
  static final List<String> hazardGoods = [
    'assets/images/rotten_fish.png',
    'assets/images/mushy_mango.png',
    'assets/images/rotten_eggplant.png',
  ];

  @override
  void initState() {
    super.initState();
    _initializeGrid();
    placeHazards();
    scanHazards();
    startTimer();
  }

  void _initializeGrid() {
    if (widget.difficulty == 'Easy') {
      numberOfSquares = 9 * 9;
      numberInEachRow = 9;
    } else if (widget.difficulty == 'Medium') {
      numberOfSquares = 9 * 9;
      numberInEachRow = 9;
    } else {
      numberOfSquares = 12 * 12; // Hard
      numberInEachRow = 12;
    }
    squareStatus = List.generate(
      numberOfSquares,
      (index) => [
        0,
        false,
        false,
        hazardLocation.contains(index)
            ? hazardGoods[Random().nextInt(hazardGoods.length)]
            : freshGoods[Random().nextInt(freshGoods.length)],
      ],
    );
  }

  void placeHazards() {
    hazardLocation.clear();
    final numberOfHazards =
        widget.difficulty == 'Easy'
            ? 10
            : widget.difficulty == 'Medium'
            ? 15
            : 25;
    final random = Random();
    final hazardSet = <int>{};
    while (hazardSet.length < numberOfHazards) {
      hazardSet.add(random.nextInt(numberOfSquares));
    }
    hazardLocation = hazardSet.toList();
    squareStatus = List.generate(
      numberOfSquares,
      (index) => [
        0,
        false,
        false,
        hazardLocation.contains(index)
            ? hazardGoods[Random().nextInt(hazardGoods.length)]
            : freshGoods[Random().nextInt(freshGoods.length)],
      ],
    );
    setState(() {});
  }

  void startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (t) {
      if (mounted) setState(() => elapsedTime++);
    });
  }

  void stopTimer() => timer?.cancel();

  void restartGame() {
    stopTimer();
    setState(() {
      hazardsRevealed = false;
      elapsedTime = 0;
      squareStatus.forEach(
        (status) =>
            status
              ..[1] = false
              ..[2] = false,
      );
    });
    placeHazards();
    scanHazards();
    startTimer();
  }

  String formatTime(int time) =>
      '${time ~/ 60}:${(time % 60).toString().padLeft(2, '0')}';

  void revealBoxNumbers(int index) {
    if (squareStatus[index][1] || squareStatus[index][2]) return;
    setState(() {
      squareStatus[index][1] = true;
      if (squareStatus[index][0] == 0) {
        _revealEmptyArea(index);
      }
    });
  }

  void _revealEmptyArea(int startingIndex) {
    final queue = Queue<int>();
    final visited = <int>{};
    queue.add(startingIndex);
    visited.add(startingIndex);
    final directions = [
      -1,
      1,
      -numberInEachRow,
      numberInEachRow,
      -numberInEachRow - 1,
      -numberInEachRow + 1,
      numberInEachRow - 1,
      numberInEachRow + 1,
    ];

    setState(() {
      while (queue.isNotEmpty) {
        final index = queue.removeFirst();
        squareStatus[index][1] = true;

        for (var dir in directions) {
          final newIndex = index + dir;
          if (_isValidNeighbor(index, newIndex) &&
              !squareStatus[newIndex][1] &&
              !squareStatus[newIndex][2] &&
              !visited.contains(newIndex)) {
            if (squareStatus[newIndex][0] == 0) {
              queue.add(newIndex);
              visited.add(newIndex);
              squareStatus[newIndex][1] = true;
            }
          }
        }
      }

      for (var index in visited) {
        for (var dir in directions) {
          final newIndex = index + dir;
          if (_isValidNeighbor(index, newIndex) &&
              !squareStatus[newIndex][1] &&
              !squareStatus[newIndex][2] &&
              squareStatus[newIndex][0] > 0) {
            squareStatus[newIndex][1] = true;
          }
        }
      }
    });
  }

  bool _isValidNeighbor(int currentIndex, int newIndex) {
    if (newIndex < 0 || newIndex >= numberOfSquares) return false;

    final currentRow = currentIndex ~/ numberInEachRow;
    final currentCol = currentIndex % numberInEachRow;
    final newRow = newIndex ~/ numberInEachRow;
    final newCol = newIndex % numberInEachRow;

    return (newRow - currentRow).abs() <= 1 && (newCol - currentCol).abs() <= 1;
  }

  void toggleFlag(int index) {
    if (squareStatus[index][1]) return;
    setState(() => squareStatus[index][2] = !squareStatus[index][2]);
  }

  void scanHazards() {
    for (var i = 0; i < numberOfSquares; i++) {
      int hazardsAround = 0;
      final directions = [
        -1,
        1,
        -numberInEachRow,
        numberInEachRow,
        -numberInEachRow - 1,
        -numberInEachRow + 1,
        numberInEachRow - 1,
        numberInEachRow + 1,
      ];
      for (var dir in directions) {
        final neighbor = i + dir;
        if (neighbor >= 0 &&
            neighbor < numberOfSquares &&
            hazardLocation.contains(neighbor)) {
          hazardsAround++;
        }
      }
      squareStatus[i][0] = hazardsAround;
    }
  }

  void playerLost() {
    stopTimer();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[700],
            title: const Text(
              'Eww bulok!',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Baho, pili ulit!',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              Center(
                child: IconButton(
                  onPressed: () {
                    restartGame();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void playerWon() {
    stopTimer();
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[700],
            title: const Text(
              'Fresh na Fresh!',
              style: TextStyle(color: Colors.white),
            ),
            content: const Text(
              'Tapos na pamimili, ulitin ulit?',
              style: TextStyle(color: Colors.white),
            ),
            actions: [
              Center(
                child: IconButton(
                  onPressed: () {
                    restartGame();
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.refresh, color: Colors.white),
                ),
              ),
            ],
          ),
    );
  }

  void checkWinner() {
    final unrevealed = squareStatus.where((s) => !s[1]).length;
    final flaggedHazards =
        squareStatus
            .where(
              (s) => s[2] && hazardLocation.contains(squareStatus.indexOf(s)),
            )
            .length;
    if (unrevealed == hazardLocation.length &&
        flaggedHazards == hazardLocation.length)
      playerWon();
  }

  @override
  void dispose() {
    stopTimer();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appBarColor =
        widget.difficulty == 'Easy'
            ? Colors.green
            : widget.difficulty == 'Medium'
            ? Colors.orange
            : Colors.red;
    final remainingHazards =
        hazardLocation.length - squareStatus.where((s) => s[2]).length;

    return Scaffold(
      appBar: AppBar(
        foregroundColor: Colors.white,
        backgroundColor: appBarColor,
        title: Text(
          'Palengke Panik - ${widget.difficulty}',
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed:
              () => Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const SplashScreen()),
              ),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/images/main_background.png'),
            fit: BoxFit.cover,
            opacity: 0.3,
          ),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: appBarColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Column(
                    children: [
                      Text(
                        remainingHazards.toString(),
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                      const Text(
                        'Bulok',
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  ),
                  IconButton(
                    onPressed: restartGame,
                    icon: Icon(Icons.refresh, color: appBarColor),
                    style: IconButton.styleFrom(backgroundColor: Colors.white),
                  ),
                  Column(
                    children: [
                      Text(
                        formatTime(elapsedTime),
                        style: const TextStyle(
                          fontSize: 36,
                          color: Colors.white,
                        ),
                      ),
                      const Text('Oras', style: TextStyle(color: Colors.white)),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                itemCount: numberOfSquares,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: numberInEachRow,
                ),
                itemBuilder:
                    (context, index) =>
                        hazardLocation.contains(index)
                            ? MyBomb(
                              revealed: hazardsRevealed,
                              flagged: squareStatus[index][2],
                              imagePath: squareStatus[index][3],
                              function: () {
                                if (!squareStatus[index][2]) {
                                  setState(() => hazardsRevealed = true);
                                  playerLost();
                                }
                              },
                              onLongPress: () => toggleFlag(index),
                            )
                            : MyNumberBox(
                              child: squareStatus[index][0],
                              revealed: squareStatus[index][1],
                              flagged: squareStatus[index][2],
                              imagePath: squareStatus[index][3],
                              function: () => revealBoxNumbers(index),
                              onLongPress: () => toggleFlag(index),
                            ),
              ),
            ),
            Container(
              padding: const EdgeInsets.all(8),
              color: const Color.fromARGB(59, 238, 238, 238),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Paano Mamili:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.touch_app, size: 20, color: Colors.blue),
                      const SizedBox(width: 4),
                      Text(
                        'Tap - Buksan ang tile',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Icon(Icons.close, size: 20, color: Colors.red),
                      const SizedBox(width: 4),
                      Text(
                        'Long Press - I-flag ang bulok',
                        style: TextStyle(fontSize: 14),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Bilhin ang sariwa, iwasan ang bulok!',
                    style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
