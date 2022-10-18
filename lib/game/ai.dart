import 'package:demo_battleship/game/connections.dart';
import 'package:demo_battleship/models/sea.dart';
import 'package:demo_battleship/util/random.dart';

import 'game.dart';

class Ai {
  late final Game game;

  bool _performing = false;

  Ai(ConnectionsWrapper connections) {
    game = Game(connections);
    game.addListener(react);
  }

  void react() async {
    if (_performing) return;
    _performing = true;
    await simulateThink();
    switch (game.phase) {
      case Phase.position:
        if (!game.playerShipsAllPositioned) put();
        break;
      case Phase.attack:
        if (game.isPlayerTurn) attack();
        break;
      default:
        break;
    }
    _performing = false;
  }

  Future<void> simulateThink() {
    return randomWait(1000, min: 1000);
  }

  void put() {
    var shipIndex = game.playerShipsAvailable.keys.first;
    List<int> availables = [];
    for (int i = 0; i < game.playerSea.data.length; i++) {
      if (game.playerSea.data[i] == FieldType.empty) availables.add(i);
    }
    // kinda brute
    do {
      availables.shuffle();
    } while (!game.put(
      index: availables.first,
      shipIndex: shipIndex,
    ));
  }

  void attack() {
    List<int> availables = [];
    for (int i = 0; i < game.enemySea.data.length; i++) {
      if (game.enemySea.data[i] == FieldType.unknown) availables.add(i);
    }
    // kinda brute
    do {
      availables.shuffle();
    } while (!game.attack(
      index: availables.first,
    ));
  }
}
