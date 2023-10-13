import 'game-state.dart';

class PuzzleState {
  PuzzleState({
    required this.puzzleType,
    required this.solved,
  });

  final PuzzleType puzzleType;
  final bool solved;

  static PuzzleState fromJson(model) {

    var puzzleType = PuzzleType.values.firstWhere((element) => element.toString().split('.').last == model['puzzleType']);
    PuzzleState p = PuzzleState(
      puzzleType: puzzleType,
      solved: model['solved'],

    );
    return p;
  }
}

enum PuzzleType
{
  Magazine,
  CoreValues,
  Bookshelf,
  GlobalMap,
  FlightBadges,
  Blinky,
  GitHub,
  DevOps,
  QA
}