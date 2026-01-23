import 'package:flutter/material.dart';
import 'package:sudoku_api/sudoku_api.dart';

class Game extends StatefulWidget {
  const Game({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<Game> createState() => _GameState();
}

class _GameState extends State<Game> {
  Puzzle? puzzle;
  int? selectedX;
  int? selectedY;

  @override
  void initState() {
    super.initState();
    _generatePuzzle();
  }

  void _generatePuzzle() async {
    try {
      PuzzleOptions puzzleOptions = PuzzleOptions();
      puzzle = Puzzle(puzzleOptions);
      await puzzle!.generate();
      setState(() {});
    } catch (e) {
      print('Error generating puzzle: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    var height = MediaQuery.of(context).size.height / 2;
    var width = MediaQuery.of(context).size.width;
    var maxSize = height > width ? width : height;
    var boxSize = (maxSize / 3).round().toDouble();

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: SizedBox(
          height: boxSize * 3,
          width: boxSize * 3,
          child: GridView.count(
            crossAxisCount: 3,
            children: List.generate(9, (x) {
              return Container(
                width: boxSize,
                height: boxSize,
                decoration:
                    BoxDecoration(border: Border.all(color: Colors.blueAccent)),
                child: GridView.count(
                  crossAxisCount: 3,
                  children: List.generate(9, (y) {
                    int val = puzzle?.board()?.matrix()?[x][y].getValue() ?? 0;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          selectedX = x;
                          selectedY = y;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5),
                          color: (selectedX == x && selectedY == y)
                              ? Colors.blueAccent.shade100.withAlpha(100)
                              : Colors.transparent,
                        ),
                        child: Center(
                          child: Text(
                            val == 0 ? '' : val.toString(),
                            style: const TextStyle(
                                fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
