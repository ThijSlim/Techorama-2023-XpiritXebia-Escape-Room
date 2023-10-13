import 'package:escape_room_game/views/game/active_game/game-artifact.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

import '../../../Palette.dart';
import '../../../models/puzzle-state.dart';

class AnimatedCollectedGameArtifact extends StatefulWidget {
  const AnimatedCollectedGameArtifact({
    super.key,
    required this.boxConstraints,
    required this.index,
    required this.logoSize,
    required this.totalArtifacts,
    required this.puzzleType,
  });


  final BoxConstraints boxConstraints;
  final int index;
  final double logoSize;
  final int totalArtifacts;
  final PuzzleType puzzleType;

  @override
  State<AnimatedCollectedGameArtifact> createState() =>
      _AnimatedCollectedGameArtifactState();
}

class _AnimatedCollectedGameArtifactState
    extends State<AnimatedCollectedGameArtifact>
    with SingleTickerProviderStateMixin {
  late AnimationController controller;


  @override
  void initState() {
    controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    controller.forward();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(builder: _buildAnimation, animation: controller);
  }

  // This function is called each time the controller "ticks" a new frame.
  Widget _buildAnimation(BuildContext context, Widget? child) {
    var biggest = widget.boxConstraints.biggest;
    double bigLogo = widget.logoSize * 2.5;
    double smallLogo = widget.logoSize;
    var size = Tween<double>(
      begin: 0.0,
      end: bigLogo,
    ).animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0.0,
          0.3,
          curve: Curves.ease,
        ),
      ),
    );


    var floatRight = widget.logoSize * (widget.totalArtifacts - widget.index - 1);

    var position = RelativeRectTween(
            begin: RelativeRect.fromSize(
                Rect.fromLTWH((biggest.width / 2) - (bigLogo / 2),
                    (biggest.height / 2) - (bigLogo / 2), bigLogo, bigLogo),
                biggest),
            end: RelativeRect.fromSize(
                Rect.fromLTWH(
                    (biggest.width - smallLogo) - floatRight, 0, smallLogo, smallLogo),
                biggest))
        .animate(
      CurvedAnimation(
        parent: controller,
        curve: const Interval(
          0.1,
          1,
          curve: Curves.elasticInOut,
        ),
      ),
    );

    return Stack(
      children: [
        Positioned(
          left: position.value.left,
          right: position.value.right,
          top: position.value.top,
          bottom: position.value.bottom,
          child: Container(
            alignment: Alignment.center,
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GameArtifact(
                puzzleType: widget.puzzleType,
                width: size.value,
                height: size.value,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
