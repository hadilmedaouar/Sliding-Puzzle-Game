import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

void main() => runApp(SlidingPuzzle());

class SlidingPuzzle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: PuzzleHome(),
    );
  }
}

class PuzzleHome extends StatefulWidget {
  @override
  _PuzzleHomeState createState() => _PuzzleHomeState();
}

class _PuzzleHomeState extends State<PuzzleHome> {
  List<int> tiles = List<int>.generate(16, (index) => index); 
  int moves = 0;
  int seconds = 0;
  Timer? timer;
  bool _isPaused = false;

  @override
  void initState() {
    super.initState();
    _shuffleTiles();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void _startTimer({bool reset = true}) {
    timer?.cancel();
    if (reset) {
      setState(() => seconds = 0); 
    }
    timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (!_isPaused) {
        setState(() => seconds++);
      }
    });
  }

  void _shuffleTiles() {
    final random = Random();
    do {
      tiles.shuffle(random);
    } while (!_isSolvable());
    setState(() {
      moves = 0;
      _isPaused = false;
    });
    _startTimer(); 
  }

  bool _isSolvable() {
    int inversions = 0;
    for (int i = 0; i < tiles.length; i++) {
      for (int j = i + 1; j < tiles.length; j++) {
        if (tiles[i] > tiles[j] && tiles[i] != 0 && tiles[j] != 0) inversions++;
      }
    }
    return inversions % 2 == 0;
  }

  void _moveTile(int index) {
    if (_isPaused) return; 
    int emptyIndex = tiles.indexOf(0);
    int row = index ~/ 4;
    int col = index % 4;
    int emptyRow = emptyIndex ~/ 4;
    int emptyCol = emptyIndex % 4;

    if ((row == emptyRow && (col - emptyCol).abs() == 1) ||
        (col == emptyCol && (row - emptyRow).abs() == 1)) {
      setState(() {
        tiles[emptyIndex] = tiles[index];
        tiles[index] = 0;
        moves++;
      });
      _checkWinCondition();
    }
  }

  void _checkWinCondition() {
    bool isSolved = true;
    for (int i = 0; i < tiles.length - 1; i++) {
      if (tiles[i] != i + 1) {
        isSolved = false;
        break;
      }
    }
    if (isSolved) {
      timer?.cancel();
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Congratulations!"),
            content: Text("You've solved the puzzle in $moves moves and $seconds seconds."),
            actions: [
              TextButton(
                child: Text("New Game"),
                onPressed: () {
                  Navigator.of(context).pop();
                  _shuffleTiles();
                },
              ),
            ],
          );
        },
      );
    }
  }

  void _togglePause() {
    setState(() {
      _isPaused = !_isPaused;
    });
    if (!_isPaused) {
      _startTimer(reset: false); 
    } else {
      timer?.cancel(); 
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 114, 8, 132),
      appBar: AppBar(
        title: Text(
          "15 Puzzle Game",
          style: TextStyle(color: const Color.fromARGB(255, 31, 237, 179)),
        ),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          SizedBox(height: 20),
          Text("15 Puzzle",
              style: TextStyle(fontSize: 35, fontWeight: FontWeight.bold, color: Colors.white)),
          SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text("Time: ${seconds}s", style: TextStyle(fontSize: 18, color: Colors.white)),
              Text("Moves: $moves", style: TextStyle(fontSize: 18, color: Colors.white)),
            ],
          ),
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(20),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 5,
                mainAxisSpacing: 5,
              ),
              itemCount: 16,
              itemBuilder: (context, index) {
                bool isInCorrectPosition = tiles[index] != 0 && tiles[index] == index + 1;

                return GestureDetector(
                  onTap: () => _moveTile(index),
                  child: Container(
                    decoration: BoxDecoration(
                      color: tiles[index] == 0
                          ? Colors.grey[300]
                          : isInCorrectPosition
                              ? const Color.fromARGB(255, 246, 127, 0)
                              : const Color.fromARGB(255, 31, 237, 179),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        tiles[index] == 0 ? '' : tiles[index].toString(),
                        style: TextStyle(fontSize: 35, color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          Text(
            "Move tiles in grid to order them from 1 to 15.",
            style: TextStyle(fontSize: 16, color: Colors.white),
          ),
          SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: _shuffleTiles,
                child: Text("New Game",
                    style: TextStyle(color: const Color.fromARGB(255, 114, 8, 132), fontSize: 20)),
              ),
              ElevatedButton(
                onPressed: _togglePause,
                child: Text(
                  _isPaused ? "Resume" : "Pause",
                  style: TextStyle(color: const Color.fromARGB(255, 114, 8, 132), fontSize: 20),
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
        ],
      ),
    );
  }
}
