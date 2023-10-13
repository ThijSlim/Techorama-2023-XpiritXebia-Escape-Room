import 'dart:io';

import 'package:dart_vlc/dart_vlc.dart';
import 'package:escape_room_game/providers/game-provider.dart';
import 'package:escape_room_game/views/audio/audio-controller-page.dart';
import 'package:escape_room_game/views/audio/audio-controller.dart';
import 'package:escape_room_game/views/dart/home-dashboard.dart';
import 'package:escape_room_game/views/leaderboard/leaderboard-page.dart';
import 'package:escape_room_game/views/network_address/network_address.dart';
import 'package:escape_room_game/views/onboard/onboard-page.dart';
import 'package:escape_room_game/views/overview/overview-page.dart';
import 'package:escape_room_game/views/playground/playground.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import 'Palette.dart';
import 'views/game/game-page.dart';
import 'views/intro/intro-page.dart';

final container = ProviderContainer();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (!kIsWeb && Platform.isWindows) {
    DartVLC.initialize();
  }

  await windowManager.ensureInitialized();

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    ref.read(listenToGameStatusProvider);
    ref.read(listenToCountdownProvider);

    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Palette.xpiritColor,
        fontFamily: 'Poppins_Regular',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const NetworkAddress(),
        '/home': (context) => const HomeDashboard(),
        '/playground': (context) => const Playground(),
        '/overview': (context) => const Overview(),
        '/audio': (context) => const AudioControllerPage(),
        '/game': (context) => const GamePage(),
        '/leaderboard': (context) => const LeaderboardPage(),
        '/onboard': (context) => const OnboardPage(),
        '/intro': (context) => const IntroPage(),
      },
    );
  }
}
