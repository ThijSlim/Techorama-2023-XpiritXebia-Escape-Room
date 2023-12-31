import 'package:flutter/material.dart';

class Palette {
  static const MaterialColor xpiritColor = const MaterialColor(
    0xffe5550b, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    const <int, Color>{
      50: const Color(0xffe5550b ),//10%
      100: const Color(0xffe5550b),//20%
      200: const Color(0xffe5550b),//30%
      300: const Color(0xffe5550b),//40%
      400: const Color(0xffe5550b),//50%
      500: const Color(0xffe5550b),//60%
      600: const Color(0xffe5550b),//70%
      700: const Color(0xffe5550b),//80%
      800: const Color(0xffe5550b),//90%
      900: const Color(0xffe5550b),//100%
    },
  );
} // y