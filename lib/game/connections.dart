import 'dart:async';

import 'package:demo_battleship/game/mock.dart';
import 'package:demo_battleship/models/communication.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import 'serializer.dart';

class ConnectionsWrapper<T> {
  final String playerId;
  final Stream<T> stream;
  final Sink<T> sink;
  final Serializer<T> serializer;

  ConnectionsWrapper({
    required this.serializer,
    required this.stream,
    required this.sink,
    required this.playerId,
  });

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
    }).onError((error) => print(error));
  }
}

ConnectionsWrapper connectToSocket(
    {required String host, int port = 80, required String playerId}) {
  // change serializer here, depends on following:
  // - socket library in and out
  // - what server expect
  // currently apparently websocket lib expects in/out as string
  // TODO: test required
  var channel = WebSocketChannel.connect(
    // Uri(
    //   scheme: "wss",
    //   host: host,
    //   port: port,
    //   queryParameters: {
    //     "room_id": "0",
    //     "access_token": playerId,
    //   },
    // ),
    Uri.parse("ws://127.0.0.1/?room_id=0&access_token=$playerId"),
  );
  return ConnectionsWrapper(
    serializer: JsonSerializer(),
    stream: channel.stream,
    sink: channel.sink,
    playerId: playerId,
  );
}

ConnectionsWrapper connectToMockServer(MockServer server,
    {required String playerId}) {
  return server.connect(playerId);
}
