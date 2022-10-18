import 'package:demo_battleship/game/game.dart';
import 'package:flutter/material.dart';

import 'sea.dart';

class EnemyBoardWidget extends StatelessWidget {
  final Game gameRef;

  const EnemyBoardWidget(this.gameRef, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 300,
      height: 300,
      child: SeaWidget(
        gameRef.enemySea,
        callback: (index) {
          gameRef.attack(index: index);
        },
      ),
    );
  }
}
