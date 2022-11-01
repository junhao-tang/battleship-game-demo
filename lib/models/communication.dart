import 'dart:convert';

import 'package:json_annotation/json_annotation.dart';

import 'ship.dart';

part 'communication.g.dart';

enum CommunicationType {
  join,
  startGame,
  put,
  enemyPut,
  attack,
  attackResult,
  enemyAttack,
}

// TODO: can we automatically generate this like using annotation or what
const _$CommunicationTypeEnumMap = {
  CommunicationType.join: 1,
  CommunicationType.startGame: 2,
  CommunicationType.put: 3,
  CommunicationType.enemyPut: 4,
  CommunicationType.attack: 5,
  CommunicationType.attackResult: 6,
  CommunicationType.enemyAttack: 7,
};

class Communication {
  final CommunicationType type;
  final Data data;

  Communication(this.type, this.data);

  Communication.put({required int index, required int shipIndex})
      : type = CommunicationType.put,
        data = PutData(shipIndex: shipIndex, index: index);

  Communication.enemyPut({required int shipIndex})
      : type = CommunicationType.enemyPut,
        data = PutData(shipIndex: shipIndex);

  Communication.attack({required int index})
      : type = CommunicationType.attack,
        data = AttackData(index: index);

  Communication.enemyAttack({required int index})
      : type = CommunicationType.enemyAttack,
        data = AttackData(index: index);

  Communication.attackResult({required int index, required bool hit})
      : type = CommunicationType.attackResult,
        data = AttackData(index: index, hit: hit);

  Communication.startGame({
    required List<Ship> ships,
    required String startingPlayerId,
    required int width,
    required int height,
  })  : type = CommunicationType.startGame,
        data = StartGameData(
          ships: ships,
          startingPlayerId: startingPlayerId,
          width: width,
          height: height,
        );

  Communication.join({required String playerId})
      : type = CommunicationType.join,
        data = PlayerIdData(playerId: playerId);

  factory Communication.fromJson(Map<String, dynamic> json) {
    var type = $enumDecode(_$CommunicationTypeEnumMap, json["type"]);
    var dataJson = jsonDecode(json['data']);
    var data = Data.fromJson(type, dataJson);
    return Communication(type, data);
  }

  Map<String, dynamic> toJson() {
    return {
      "type": _$CommunicationTypeEnumMap[type],
      "data": jsonEncode(data.toJson()),
    };
  }
}

abstract class Data {
  Data();
  Map<String, dynamic> toJson();
  factory Data.fromJson(CommunicationType type, Map<String, dynamic> json) {
    // TODO  required improvement
    switch (type) {
      case CommunicationType.attack:
      case CommunicationType.attackResult:
      case CommunicationType.enemyAttack:
        return AttackData.fromJson(json);
      case CommunicationType.put:
      case CommunicationType.enemyPut:
        return PutData.fromJson(json);
      case CommunicationType.startGame:
        return StartGameData.fromJson(json);
      case CommunicationType.join:
        return PlayerIdData.fromJson(json);

      default:
        throw Exception("unknown deserialize");
    }
  }
}

@JsonSerializable()
class AttackData extends Data {
  final int index;
  final bool? hit;

  AttackData({
    required this.index,
    this.hit,
  });
  factory AttackData.fromJson(Map<String, dynamic> json) =>
      _$AttackDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$AttackDataToJson(this);
}

@JsonSerializable()
class PutData extends Data {
  final int? index;
  final int shipIndex;

  PutData({
    required this.shipIndex,
    this.index,
  });

  factory PutData.fromJson(Map<String, dynamic> json) =>
      _$PutDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PutDataToJson(this);
}

@JsonSerializable()
class PlayerIdData extends Data {
  final String playerId;

  PlayerIdData({
    required this.playerId,
  });

  factory PlayerIdData.fromJson(Map<String, dynamic> json) =>
      _$PlayerIdDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$PlayerIdDataToJson(this);
}

@JsonSerializable()
class StartGameData extends Data {
  final String startingPlayerId;
  final int width;
  final int height;
  final List<Ship> ships;

  StartGameData({
    required this.ships,
    required this.startingPlayerId,
    required this.width,
    required this.height,
  });

  factory StartGameData.fromJson(Map<String, dynamic> json) =>
      _$StartGameDataFromJson(json);
  @override
  Map<String, dynamic> toJson() => _$StartGameDataToJson(this);
}
