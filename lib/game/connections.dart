import 'dart:async';

import 'package:demo_battleship/game/mock.dart';
import 'package:demo_battleship/models/communication.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'serializer.dart';

class ConnectionsWrapper<T> {
  final Stream<T> stream;
  final Sink<T> sink;
  final Serializer<T> serializer;

  ConnectionsWrapper(this.serializer, this.stream, this.sink);

  void send(Communication communication) {
    sink.add(
      serializer.serialize(communication),
    );
  }

  void addListener(Function(Communication communication) callback) {
    stream.listen((data) {
      callback(
        serializer.deserialize(data),
      );
    });
  }
}

ConnectionsWrapper connectToSocket(String uri, {required String playerId}) {
  // change serializer here, depends on following:
  // - socket library in and out
  // - what server expect
  // currently apparently websocket lib expects in/out as string
  // TODO: test required
  var channel = WebSocketChannel.connect(Uri.parse(uri));
  return ConnectionsWrapper(JsonSerializer(), channel.stream, channel.sink);
}

ConnectionsWrapper connectToMockServer(MockServer server,
    {required String playerId}) {
  return server.connect(playerId);
}
