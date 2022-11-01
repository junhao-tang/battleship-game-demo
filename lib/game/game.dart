import 'package:demo_battleship/game/connections.dart';
import 'package:demo_battleship/models/communication.dart';
import 'package:demo_battleship/models/sea.dart';
import 'package:demo_battleship/models/ship.dart';
import 'package:flutter/foundation.dart';

enum Phase {
  initialize,
  position,
  attack,
}

class Game extends ChangeNotifier {
  late final Sea playerSea;
  late final Sea enemySea;
  late final List<Ship> ships;

  final Map<int, bool> playerShipsAvailable = {};
  final Map<int, bool> enemyShipsAvailable = {};
  final List<Communication> history = [];

  Phase phase = Phase.initialize;
  bool isPlayerTurn = false;
  ConnectionsWrapper connections;

  Game(this.connections) {
    connections.addListener(
      (communication) {
        switch (communication.type) {
          case CommunicationType.startGame:
            var data = communication.data as StartGameData;
            _init(
              playerFirst: data.startingPlayerId == connections.playerId,
              ships: data.ships,
              width: data.width,
              height: data.height,
            );
            break;
          case CommunicationType.put:
            var data = communication.data as PutData;
            _put(
              index: data.index!,
              shipIndex: data.shipIndex,
            );
            break;
          case CommunicationType.enemyPut:
            var data = communication.data as PutData;
            _enemyPut(shipIndex: data.shipIndex);
            break;
          case CommunicationType.enemyAttack:
            var data = communication.data as AttackData;
            _enemyAttack(index: data.index);
            break;
          case CommunicationType.attackResult:
            var data = communication.data as AttackData;
            _attack(
              index: data.index,
              hit: data.hit!,
            );
            break;
          case CommunicationType.join:
            break;
          default:
            return;
        }
        history.add(communication);
        notifyListeners();
      },
    );
  }

  bool get playerShipsAllPositioned => playerShipsAvailable.isEmpty;
  bool get enemyShipsAllPositioned => enemyShipsAvailable.isEmpty;

  bool put({required int index, required int shipIndex}) {
    if (playerShipsAvailable[shipIndex] == null) return false;
    var ship = ships[shipIndex];
    if (!playerSea.canPut(index, ship.width, ship.height)) return false;
    connections.send(Communication.put(index: index, shipIndex: shipIndex));
    return true;
  }

  bool attack({required int index}) {
    if (!isPlayerTurn) return false;
    if (enemySea.canAttack(index)) {
      connections.send(Communication.attack(index: index));
      return true;
    }
    return false;
  }

  void _init({
    required bool playerFirst,
    required List<Ship> ships,
    required int width,
    required int height,
  }) {
    enemySea = Sea.enemy(width, height);
    playerSea = Sea.player(width, height);
    for (int i = 0; i < ships.length; i++) {
      playerShipsAvailable[i] = true;
      enemyShipsAvailable[i] = true;
    }
    this.ships = ships;
    isPlayerTurn = playerFirst;
    phase = Phase.position;
  }

  void _put({required int index, required int shipIndex}) {
    var ship = ships[shipIndex];
    playerSea.put(index, ship.width, ship.height);
    playerShipsAvailable.remove(shipIndex);
    if (enemyShipsAllPositioned && playerShipsAllPositioned) {
      phase = Phase.attack;
    }
  }

  void _enemyPut({required int shipIndex}) {
    enemyShipsAvailable.remove(shipIndex);
    if (enemyShipsAllPositioned && playerShipsAllPositioned) {
      phase = Phase.attack;
    }
  }

  void _attack({required int index, required bool hit}) {
    if (hit) {
      enemySea.set(index, FieldType.hit);
    } else {
      enemySea.set(index, FieldType.missed);
    }
    isPlayerTurn = false;
  }

  void _enemyAttack({required int index}) {
    if (playerSea.isOccupied(index)) {
      playerSea.set(index, FieldType.hit);
    } else {
      playerSea.set(index, FieldType.missed);
    }
    isPlayerTurn = true;
  }
}
