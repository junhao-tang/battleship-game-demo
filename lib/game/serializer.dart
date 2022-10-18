import 'dart:convert';

import 'package:demo_battleship/models/communication.dart';

abstract class Serializer<T> {
  Communication deserialize(T data);
  T serialize(Communication communication);
}

class ByteJsonSerializer extends Serializer<List<int>> {
  @override
  Communication deserialize(List<int> data) {
    var json = jsonDecode(utf8.decode(data));
    return Communication.fromJson(json);
  }

  @override
  List<int> serialize(Communication communication) {
    var json = jsonEncode(communication.toJson());
    return utf8.encode(json);
  }
}

class JsonSerializer extends Serializer<String> {
  @override
  Communication deserialize(String data) {
    var json = jsonDecode(data);
    return Communication.fromJson(json);
  }

  @override
  String serialize(Communication communication) {
    var json = jsonEncode(communication.toJson());
    return json;
  }
}
