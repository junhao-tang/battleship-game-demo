import 'package:json_annotation/json_annotation.dart';

part 'ship.g.dart';

@JsonSerializable()
class Ship {
  final int width;
  final int height;

  const Ship(this.width, this.height);

  factory Ship.fromJson(Map<String, dynamic> json) => _$ShipFromJson(json);
  Map<String, dynamic> toJson() => _$ShipToJson(this);
}
