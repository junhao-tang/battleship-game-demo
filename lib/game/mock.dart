import 'dart:async';

import 'package:demo_battleship/game/connections.dart';
import 'package:demo_battleship/game/serializer.dart';
import 'package:demo_battleship/models/communication.dart';
import 'package:demo_battleship/models/sea.dart';
import 'package:demo_battleship/models/ship.dart';

import 'connections.dart';

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

  late final Map<String, Sea> playersSea = {};
  late final Map<String, StreamControllerWrapper<T>> playersConn = {};

  MockServer(this.serializer);

  ConnectionsWrapper<T> connect(String id) {
    if (playersConn.length == maxPlayers) throw Exception("reached max");
    if (playersConn[id] == null) {
      _handleJoin(id);
      if (playersConn.length == maxPlayers) _handleStartGame();
    }
    var conn = playersConn[id]!;

    return ConnectionsWrapper<T>(
      serializer,
      conn.outSc.stream,
      conn.inSc.sink,
    );
  }

  Function(T) handlerFn(String playerId) {
    return (T data) {
      var communication = serializer.deserialize(data);
      switch (communication.type) {
        case CommunicationType.put:
          var data = communication.data as PutData;
          _handlePutRequest(playerId, data.index!, data.shipIndex);
          break;
        case CommunicationType.attack:
          var data = communication.data as AttackData;
          _handleAttackRequest(playerId, data.index);
          break;
        default:
          break;
      }
    };
  }

  void _writeTo(Communication data, String playerId) {
    playersConn[playerId]!.outSc.add(serializer.serialize(data));
  }

  void _boardCast(Communication data, {String? except}) {
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
      _writeTo(
        Communication.startGame(
          ships: ships,
          playerGoFirst: id == participantsId.first,
          width: width,
          height: height,
        ),
        id,
      );
    }
  }

  void _handleJoin(String id) {
    var inSc = StreamController<T>();
    var outSc = StreamController<T>();
    inSc.stream.listen(handlerFn(id));
    playersConn[id] = StreamControllerWrapper(inSc, outSc);
    _boardCast(Communication.join(playerId: id));
  }

  void _handlePutRequest(String playerId, int index, int shipIndex) {
    Sea sea = playersSea[playerId]!;
    var ship = ships[shipIndex];
    if (sea.canPut(index, ship.width, ship.height)) {
      sea.put(index, ship.width, ship.height);
      _writeTo(Communication.put(index: index, shipIndex: shipIndex), playerId);
      _boardCast(Communication.enemyPut(shipIndex: shipIndex),
          except: playerId);
    }
  }

  void _handleAttackRequest(String playerId, int index) {
    Sea enemySea = playersSea[playersSea.keys
        .where(
          (id) => playerId != id,
        )
        .first]!;
    if (enemySea.canAttacked(index)) {
      var hit = enemySea.isOccupied(index);
      _writeTo(Communication.attackResult(index: index, hit: hit), playerId);
      _boardCast(Communication.enemyAttack(index: index), except: playerId);
    }
  }
}
