import 'package:audioplayers/audioplayers.dart';
import 'package:escape_room_game/models/puzzle-state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/game-state.dart';
import '../../providers/game-provider.dart';

class AudioController extends ConsumerStatefulWidget {
  const AudioController({Key? key}) : super(key: key);

  @override
  ConsumerState<AudioController> createState() => _AudioControllerState();
}

class _AudioControllerState extends ConsumerState<AudioController> {
  AudioPlayer backgroundAudioPlayer = AudioPlayer();
  AudioPlayer timeBackgroundAudioPlayer = AudioPlayer();
  AudioPlayer soundEffectAudioPlayer = AudioPlayer();
  AudioPlayer gameCompletedAudioPlayer = AudioPlayer();

  String audioAssetPath = "audios";

  @override
  void dispose() {
    backgroundAudioPlayer.stop();
    timeBackgroundAudioPlayer.stop();
    soundEffectAudioPlayer.stop();
    gameCompletedAudioPlayer.stop();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<Duration>(gameTimeProvider,
        (Duration? previousTime, Duration currentTime) {
      var gameStatus = ref.read(gameStatusProvider);

      if (currentTime.inSeconds <= 31 && gameStatus == GameStatus.InProgress) {
        playAudioTimeIsRunningOut();
      }
    });

    ref.listen<GameStatus>(gameStatusProvider,
        (GameStatus? previousGameStatus, GameStatus currentGameStatus) {
      if (currentGameStatus == GameStatus.Intro) {
        playTeamBoardingAudio();
      }

      if (currentGameStatus == GameStatus.ReadyToStart) {
        playBackgroundAudio();
      }

      if (currentGameStatus == GameStatus.InProgress) {
        cancelSoundEffects();
        playAudioClockTicking();
      }

      if (currentGameStatus == GameStatus.Completed) {
        stopBackgroundAudio();
        stopTimeBackgroundAudio();

        playAudioGameCompleted();
      }
    });

    ref.listen<Duration>(timeTillHintEnabledProvider,
        (Duration? previousGameStatus, Duration currentGameStatus) {
      if (previousGameStatus == null) {
        return;
      }

      var gameStatus = ref.read(gameStatusProvider);
      if (gameStatus != GameStatus.InProgress) {
        return;
      }

      if (previousGameStatus.inSeconds == 1 &&
          currentGameStatus.inSeconds == 0) {
        playHintEnabledAudio();
      }
    });

    ref.listen<int?>(readyToStartCountdownStateNotifier, (previous, next) {
      var gameStatus = ref.read(gameStatusProvider);
      if (next == 5 && gameStatus == GameStatus.ReadyToStart) {
        play5SecondCountDownAudio();
      }
    });

    ref.listen<String?>(hintActivatedProvider,
        (String? previousHintActivated, String? currentHintActivated) {
      if (previousHintActivated == null && currentHintActivated != null) {
        playHintActivatedAudio();
      }
    });

    ref.listen<Duration?>(timeTillNextAnswerTryProvider,
        (Duration? previousGameStatus, Duration? currentGameStatus) {
      if (previousGameStatus == null && currentGameStatus != null) {
        playFailureDrum();
      }
    });

    ref.listen<List<PuzzleState>>(gameProgressProvider,
        (List<PuzzleState>? previousHintActivated,
            List<PuzzleState> currentHintActivated) {
      if (previousHintActivated == null) {
        return;
      }

      var previousSolvedPuzzles =
          previousHintActivated.where((element) => element.solved).toList();
      var currentSolvedPuzzles =
          currentHintActivated.where((element) => element.solved).toList();

      if (previousSolvedPuzzles.length < currentSolvedPuzzles.length) {
        playCorrectAnswer();
      }
    });

    return Container(
        color: Colors.black,
        child: const Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Keep this window open for audio to play",
                style: TextStyle(color: Colors.white)),
          ],
        ));
  }

  renderAudioPlaying(String type, String audioPath) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 200,
          child: Text(
            '$type audio playing: ',
            style: const TextStyle(color: Colors.white),
          ),
        ),
        const SizedBox(width: 10),
        SizedBox(
          width: 300,
          child: Text(
            audioPath,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }

  String getAssetAudioPath(AudioPlayer audioController) {
    return audioController.source.toString();
  }

  void playSoundBySolved(List<PuzzleState> puzzles, int index) {
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (index >= puzzles.length - 1) {
        playFinalSound(puzzles);
        return;
      }

      var puzzleSolved = puzzles[index].solved;

      if (puzzleSolved) {
        playCorrectAnswer();
      } else {
        playHitSound();
      }

      int nextIndex = index + 1;
      playSoundBySolved(puzzles, nextIndex);
    });
  }

  void cancelSoundEffects(){
    soundEffectAudioPlayer.stop();
  }

  void playFinalSound(List<PuzzleState> puzzles) {
    var allPuzzlesSolved = puzzles.every((element) => element.solved);

    if (allPuzzlesSolved) {
      playGameCompletedSound();
    } else {
      playGameFailedSound();
    }
  }

  void playTeamBoardingAudio() {
    soundEffectAudioPlayer.play(AssetSource("$audioAssetPath/airport-open.mp3"),
        volume: 1);

    setState(() {});
  }

  void play5SecondCountDownAudio() {
    soundEffectAudioPlayer
        .play(AssetSource("$audioAssetPath/5-second-countdown.mp3"), volume: 1);

    setState(() {});
  }

  void playBackgroundAudio() {
    backgroundAudioPlayer.play(
        AssetSource("$audioAssetPath/dark-background-sounds.mp3"),
        volume: 1);

    setState(() {});
  }

  void playHintEnabledAudio() {
    soundEffectAudioPlayer.play(
        AssetSource("$audioAssetPath/airplane-notification.mp3"),
        volume: 1);

    setState(() {});
  }

  void playHintActivatedAudio() {
    soundEffectAudioPlayer
        .play(AssetSource("$audioAssetPath/mayday-mayday.mp3"), volume: 0.7);

    setState(() {});
  }

  void playFailureDrum() {
    soundEffectAudioPlayer.play(AssetSource("$audioAssetPath/failure-drum.mp3"),
        volume: 1);

    setState(() {});
  }

  void playCorrectAnswer() {
    soundEffectAudioPlayer.play(
        AssetSource("$audioAssetPath/answer-correct.mp3"),
        volume: 1,
        position: const Duration(seconds: 0));

    setState(() {});
  }

  void playAudioClockTicking() {
    timeBackgroundAudioPlayer
        .play(AssetSource("$audioAssetPath/clock-ticking.mp3"), volume: 0.5);

    setState(() {});
  }

  void playAudioTimeIsRunningOut() {
    timeBackgroundAudioPlayer.play(
        AssetSource("$audioAssetPath/time-is-running-out.mp3"),
        volume: 0.8);

    setState(() {});
  }

  void stopTimeBackgroundAudio() {
    timeBackgroundAudioPlayer.stop();
  }

  void stopBackgroundAudio() {
    backgroundAudioPlayer.stop();
  }

  void playAudioGameCompleted() {
    var gameProgress = ref.watch(gameProgressProvider);

    var puzzles = gameProgress.toList();

    playSoundBySolved(puzzles, 0);
  }

  void playGameCompletedCorrect() {
    gameCompletedAudioPlayer.play(
        AssetSource("$audioAssetPath/answer-correct.mp3"),
        volume: 0.8,
        position: const Duration(seconds: 0));

    setState(() {});
  }

  void playGameCompletedSound() {
    gameCompletedAudioPlayer
        .play(AssetSource("$audioAssetPath/game-completed.mp3"), volume: 1);

    setState(() {});
  }

  void playGameFailedSound() {
    gameCompletedAudioPlayer
        .play(AssetSource("$audioAssetPath/sad-orchestra.mp3"), volume: 1);

    setState(() {});
  }

  void playHitSound() {
    gameCompletedAudioPlayer.release();
    gameCompletedAudioPlayer.play(
      AssetSource("$audioAssetPath/hit-sound.mp3"),
      volume: 0.8,
      position: const Duration(seconds: 0),
    );

    setState(() {});
  }
}
