// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'communication.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AttackData _$AttackDataFromJson(Map<String, dynamic> json) => AttackData(
      index: json['index'] as int,
      hit: json['hit'] as bool?,
    );

Map<String, dynamic> _$AttackDataToJson(AttackData instance) =>
    <String, dynamic>{
      'index': instance.index,
      'hit': instance.hit,
    };

PutData _$PutDataFromJson(Map<String, dynamic> json) => PutData(
      shipIndex: json['shipIndex'] as int,
      index: json['index'] as int?,
    );

Map<String, dynamic> _$PutDataToJson(PutData instance) => <String, dynamic>{
      'index': instance.index,
      'shipIndex': instance.shipIndex,
    };

PlayerIdData _$PlayerIdDataFromJson(Map<String, dynamic> json) => PlayerIdData(
      playerId: json['playerId'] as String,
    );

Map<String, dynamic> _$PlayerIdDataToJson(PlayerIdData instance) =>
    <String, dynamic>{
      'playerId': instance.playerId,
    };

StartGameData _$StartGameDataFromJson(Map<String, dynamic> json) =>
    StartGameData(
      ships: (json['ships'] as List<dynamic>)
          .map((e) => Ship.fromJson(e as Map<String, dynamic>))
          .toList(),
      startingPlayerId: json['startingPlayerId'] as String,
      width: json['width'] as int,
      height: json['height'] as int,
    );

Map<String, dynamic> _$StartGameDataToJson(StartGameData instance) =>
    <String, dynamic>{
      'startingPlayerId': instance.startingPlayerId,
      'width': instance.width,
      'height': instance.height,
      'ships': instance.ships,
    };
