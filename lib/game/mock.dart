import 'dart:async';
import 'dart:developer';

import 'package:demo_battleship/game/connections.dart';
import 'package:demo_battleship/game/serializer.dart';
import 'package:demo_battleship/models/communication.dart';
import 'package:demo_battleship/models/sea.dart';
import 'package:demo_battleship/models/ship.dart';

import 'connections.dart';
import 'game.dart';

class StreamControllerWrapper<T> {
  final StreamController<T> inSc;
  final StreamController<T> outSc;
  StreamControllerWrapper(this.inSc, this.outSc);
}

class MockServer<T> {
  static const int width = 8;
  static const int height = 8;
  static const List<Ship> ships = [
    Ship(1, 4),
    Ship(4, 1),
    Ship(2, 2),
    Ship(3, 3),
  ];
  static const int maxPlayers = 2;

  final Serializer<T> serializer;

  late final Map<String, Map<int, bool>> playersUsedShip = {};
  late final Map<String, Sea> playersSea = {};
  late final Map<String, StreamControllerWrapper<T>> playersConn = {};
  Phase _phase = Phase.initialize;

  MockServer(this.serializer);

  ConnectionsWrapper<T> connect(String id) {
    if (playersConn.length == maxPlayers) throw Exception("reached max");
    if (playersConn[id] == null) {
      _handleJoin(id);
      if (playersConn.length == maxPlayers) _handleStartGame();
    } // for actual server, we will disconnect the previous connections
    var conn = playersConn[id]!;

    return ConnectionsWrapper<T>(
      serializer: serializer,
      stream: conn.outSc.stream,
      sink: conn.inSc.sink,
      playerId: id,
    );
  }

  Function(T) handlerFn(String playerId) {
    return (T data) {
      try {
        var communication = serializer.deserialize(data);
        switch (communication.type) {
          case CommunicationType.put:
            var data = communication.data as PutData;
            if (data.index == null ||
                data.index! < 0 ||
                data.index! >= width * height) return;
            if (data.shipIndex < 0 || data.shipIndex >= ships.length) return;
            _handlePutRequest(playerId, data.index!, data.shipIndex);
            break;
          case CommunicationType.attack:
            var data = communication.data as AttackData;
            if (data.index < 0 || data.index >= width * height) return;
            _handleAttackRequest(playerId, data.index);
            break;
          default:
            break;
        }
      } catch (e) {
        log(e.toString());
      }
    };
  }

  void _writeTo(Communication data, String playerId) {
    playersConn[playerId]!.outSc.add(serializer.serialize(data));
  }

  void _broadcast(Communication data, {String? except}) {
    for (var id in playersConn.keys) {
      if (id == except) continue;
      _writeTo(data, id);
    }
  }

  void _handleStartGame() {
    var participantsId = playersConn.keys.toList();
    participantsId.shuffle();

    for (var id in participantsId) {
      playersSea[id] = Sea.player(width, height);
      playersUsedShip[id] = {};
      _writeTo(
        Communication.startGame(
          ships: ships,
          startingPlayerId: participantsId.first,
          width: width,
          height: height,
        ),
        id,
      );
    }

    _phase = Phase.position;
  }

  void _handleJoin(String id) {
    var inSc = StreamController<T>();
    var outSc = StreamController<T>();
    inSc.stream.listen(handlerFn(id));
    playersConn[id] = StreamControllerWrapper(inSc, outSc);
    _broadcast(Communication.join(playerId: id));
  }

  bool get allShipsPlaced => playersUsedShip.entries.every(
        (e) => e.value.length == ships.length,
      );

  void _handlePutRequest(String playerId, int index, int shipIndex) {
    if (_phase != Phase.position) return;
    if (playersUsedShip[playerId]![shipIndex] != null) return; // ignored
    Sea sea = playersSea[playerId]!;
    var ship = ships[shipIndex];
    if (sea.canPut(index, ship.width, ship.height)) {
      sea.put(index, ship.width, ship.height);
      playersUsedShip[playerId]![shipIndex] = true;
      _writeTo(Communication.put(index: index, shipIndex: shipIndex), playerId);
      _broadcast(Communication.enemyPut(shipIndex: shipIndex),
          except: playerId);
      if (allShipsPlaced) {
        _phase = Phase.attack;
      }
    }
  }

  void _handleAttackRequest(String playerId, int index) {
    if (_phase != Phase.attack) return;
    Sea enemySea = playersSea[playersSea.keys
        .where(
          (id) => playerId != id,
        )
        .first]!;
    if (enemySea.canAttacked(index)) {
      var hit = enemySea.isOccupied(index);
      _writeTo(Communication.attackResult(index: index, hit: hit), playerId);
      _broadcast(Communication.enemyAttack(index: index), except: playerId);
    }
  }
}
