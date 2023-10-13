import 'dart:async';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:escape_room_game/models/game-state.dart';
import 'package:escape_room_game/models/puzzle-state.dart';
import 'package:escape_room_game/providers/ip-address-provider.dart';
import 'package:flutter/foundation.dart';
import 'package:http/io_client.dart';

import '../main.dart';



var headers = {
  'Content-Type': 'application/json',
  'Accept': 'application/json',
  'ngrok-skip-browser-warning': '1',
};

IOClient getHttpClient() {
  final ioc = new HttpClient();
  ioc.badCertificateCallback =
      (X509Certificate cert, String host, int port) => true;
  final http = new IOClient(ioc);
  return http;
}

String getUrl() {
  var backendIpAddress = container.read(backendIpAddressStateProvider);
  var apiUrl = '$backendIpAddress:5120';
  return apiUrl;
}

Future<GameState> fetchGameState() async {
  var http = getHttpClient();

  var apiUrl = getUrl();
  var uri = Uri.http(apiUrl, '/Game/currentGameState');
  final response = await http.get(uri, headers: headers);

  var responseJson = json.decode(response.body);
  if (response.statusCode != 200) {
    throw Exception('Failed to load data');
  }

  return GameState.fromJson(responseJson);
}

Future<bool> postAnswer(num answer) async {
  var http = getHttpClient();
  var apiUrl = getUrl();

  var uri = Uri.http(apiUrl, '/Game/answerQuestion');
  var response = await http.post(uri,
      headers: headers, body: json.encode({'answer': answer}));

  var responseJson = json.decode(response.body);

  return responseJson['isCorrect'];
}

Future<void> postStartGame() async {
  var http = getHttpClient();
  var apiUrl = getUrl();

  var uri = Uri.http(apiUrl, '/Game/startGame');
  await http.post(
    uri,
    headers: headers,
  );
}

Future<void> postReadyGame() async {
  var http = getHttpClient();
  var apiUrl = getUrl();

  var uri = Uri.http(apiUrl, '/Game/readyGame');
  await http.post(
    uri,
    headers: headers,
  );
}

Future<void> postEndGame() async {
  var http = getHttpClient();
  var apiUrl = getUrl();

  var uri = Uri.http(apiUrl, '/Game/endGame');
  await http.post(
    uri,
    headers: headers,
  );
}

Future<void> postActivateHint() async {
  var http = getHttpClient();
  var apiUrl = getUrl();

  var uri = Uri.http(apiUrl, '/Game/activateHint');
  await http.post(
    uri,
    headers: headers,
  );
}

Future<void> postNewTeam(String teamName, List<String> players) async {
  var http = getHttpClient();
  var apiUrl = getUrl();

  var uri = Uri.http(apiUrl, '/Team/newTeam');
  await http.post(uri,
      headers: headers,
      body: json.encode({'TeamName': teamName, 'PlayerNames': players}));
}

//fetchLeaderboard
Future<List<LeaderboardTeam>> fetchLeaderboard() async {
  var http = getHttpClient();
  var apiUrl = getUrl();

  var uri = Uri.http(apiUrl, '/Team/leaderboard');
  var response = await http.get(
    uri,
    headers: headers,
  );

  if (response.statusCode == 200) {
    var responseJson = json.decode(response.body);
    var leaderboardList =
        (responseJson as List).map((i) => LeaderboardTeam.fromJson(i)).toList();
    return leaderboardList;
  } else {
    throw Exception(response.statusCode);
  }
}

class LeaderboardTeam {
  final String teamName;
  final Duration timeLeft;
  final List<String> playerNames;
  final List<PuzzleState> puzzles;
  final bool gameCompletedSuccessful;

  LeaderboardTeam(
      {required this.teamName,
      required this.timeLeft,
      required this.gameCompletedSuccessful,
      required this.puzzles,
      required this.playerNames});

  factory LeaderboardTeam.fromJson(Map<String, dynamic> json) {
    return LeaderboardTeam(
        teamName: json['teamName'],
        timeLeft: parseDuration(json['timeLeft']),
        playerNames:
            (json['playerNames'] as List).map((e) => e as String).toList(),
        puzzles: (json['puzzles'] as List)
            .map((e) => PuzzleState.fromJson(e))
            .toList(),
        gameCompletedSuccessful: json['gameCompletedSuccessful']);
  }
}
