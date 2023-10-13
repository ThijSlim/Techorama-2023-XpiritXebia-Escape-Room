import 'package:escape_room_game/models/puzzle-state.dart';

class GameState {
  GameState({
    required this.activeQuestion,
    required this.activeTeam,
    required this.gameCompletedSuccessful,
    required this.timeLeft,
    required this.gameStatus,
    required this.gameProgress,
    required this.activatedHint,
    required this.timeTillHintIsEnabled,
    required this.timeTillNextAnswerTry,
  });

  final String? activeQuestion;
  final String? activeTeam;
  final String? activatedHint;
  final Duration? timeTillHintIsEnabled;
  final Duration? timeTillNextAnswerTry;
  final bool? gameCompletedSuccessful;
  final Duration? timeLeft;
  final GameStatus gameStatus;
  final List<PuzzleState> gameProgress;

  static fromJson(Map<String, dynamic> responseJson){
    var timeLeft = parseDuration(responseJson['timeLeft']);
    var gameStatus = GameStatus.values[responseJson['gameStatus']];
    var activeQuestion = responseJson['activeQuestion'];
    var activeTeam = responseJson['activeTeam'];
    var activatedHint = responseJson['activatedHint'];
    var timeTillHintIsEnabled = responseJson['timeTillHintIsEnabled'] != null ? parseDuration(responseJson['timeTillHintIsEnabled']) : null;
    var timeTillNextAnswerTry = responseJson['timeTillNextAnswerTry'] != null ? parseDuration(responseJson['timeTillNextAnswerTry']) : null;
    var gameCompletedSuccessful = responseJson['gameCompletedSuccessful'];
    List<PuzzleState> gameProgress = (responseJson['gameProgress'] as List)
        .map((i) => PuzzleState.fromJson(i))
        .toList();

    return GameState(
      activeQuestion: activeQuestion,
      activeTeam: activeTeam,
      gameCompletedSuccessful: gameCompletedSuccessful,
      timeLeft: timeLeft,
      gameStatus: gameStatus,
      gameProgress: gameProgress,
      activatedHint: activatedHint,
      timeTillHintIsEnabled: timeTillHintIsEnabled,
      timeTillNextAnswerTry: timeTillNextAnswerTry,
    );
  }
}


Duration parseDuration(String durationString) {
  try {
    List<String> parts = durationString.split('.')[0].split(':');
    int hours = parts.length > 0 ? int.parse(parts[0]) : 0;
    int minutes = parts.length > 1 ? int.parse(parts[1]) : 0;
    int seconds = parts.length > 2 ? int.parse(parts[2]) : 0;
    return Duration(hours: hours, minutes: minutes, seconds: seconds);
  } catch (e) {
    throw FormatException('Invalid duration format: $durationString');
  }
}

enum GameStatus
{
  Idle,
  Intro,
  ReadyToStart,
  InProgress,
  Completed,
}