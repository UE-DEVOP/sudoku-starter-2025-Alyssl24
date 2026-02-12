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
  List<List<bool>> isPrefilled = List.generate(9, (_) => List.filled(9, false));

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

      isPrefilled = List.generate(9, (_) => List.filled(9, false));
      for (int x = 0; x < 9; x++) {
        for (int y = 0; y < 9; y++) {
          final v = puzzle?.board()?.matrix()?[x][y].getValue() ?? 0;
          isPrefilled[x][y] = (v != 0);
        }
      }

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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // ===== GRILLE =====
            SizedBox(
              height: boxSize * 3,
              width: boxSize * 3,
              child: GridView.count(
                crossAxisCount: 3,
                children: List.generate(9, (x) {
                  return Container(
                    width: boxSize,
                    height: boxSize,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.blueAccent),
                    ),
                    child: GridView.count(
                      crossAxisCount: 3,
                      children: List.generate(9, (y) {
                        int val =
                            puzzle?.board()?.matrix()?[x][y]?.getValue() ?? 0;
                        int expected = puzzle
                                ?.solvedBoard()
                                ?.matrix()?[x][y]
                                ?.getValue() ??
                            0;

                        final locked =
                            (puzzle == null) ? true : isPrefilled[x][y];
                        return InkWell(
                          onTap: locked
                              ? null
                              : () {
                                  setState(() {
                                    selectedX = x;
                                    selectedY = y;
                                  });
                                },
                          child: Container(
                            decoration: BoxDecoration(
                              border:
                                  Border.all(color: Colors.black, width: 0.5),
                              color: (selectedX == x && selectedY == y)
                                  ? Colors.blueAccent.shade100.withAlpha(100)
                                  : Colors.transparent,
                            ),
                            child: Center(
                              child: Text(
                                val == 0 ? expected.toString() : val.toString(),
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color:
                                      val == 0 ? Colors.black12 : Colors.black,
                                ),
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

            const SizedBox(height: 20),

            // ===== BOUTONS 1 → 5 =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      if (puzzle == null ||
                          selectedX == null ||
                          selectedY == null ||
                          isPrefilled[selectedX!][selectedY!]) return;

                      int value = i + 1;
                      final Position pos =
                          Position(row: selectedX!, column: selectedY!);

                      setState(() {
                        puzzle!.board()!.cellAt(pos).setValue(value);
                      });
                    },
                    child: Text('${i + 1}'),
                  ),
                );
              }),
            ),

            const SizedBox(height: 8),

            // ===== BOUTONS 6 → 9 =====
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (i) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    onPressed: () {
                      if (puzzle == null ||
                          selectedX == null ||
                          selectedY == null ||
                          isPrefilled[selectedX!][selectedY!]) return;

                      int value = i + 6;
                      final Position pos =
                          Position(row: selectedX!, column: selectedY!);

                      setState(() {
                        puzzle!.board()!.cellAt(pos).setValue(value);
                      });
                    },
                    child: Text('${i + 6}'),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
