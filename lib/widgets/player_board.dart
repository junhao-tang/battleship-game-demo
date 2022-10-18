import 'package:demo_battleship/game/game.dart';
import 'package:flutter/material.dart';

import 'sea.dart';

class PlayerBoardWidget extends StatelessWidget {
  final Game gameRef;

  const PlayerBoardWidget(this.gameRef, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: SeaWidget(
        gameRef.playerSea,
        callback: (index) {
          if (!gameRef.playerShipsAllPositioned) {
            gameRef.put(
              index: index,
              shipIndex: gameRef.playerShipsAvailable.keys.first,
            );
          }
        },
      ),
    );
  }
}
