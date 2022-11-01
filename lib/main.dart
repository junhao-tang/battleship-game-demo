import 'package:demo_battleship/game/ai.dart';
import 'package:demo_battleship/game/connections.dart';
import 'package:demo_battleship/game/mock.dart';
import 'package:demo_battleship/game/serializer.dart';
import 'package:demo_battleship/widgets/enemy_board.dart';
import 'package:demo_battleship/widgets/player_board.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'game/game.dart';
import 'util/random.dart';

bool isSinglePlayer = true;
String serverHost = "127.0.0.1";
String playerId = generateId();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Game gameRef;
  if (isSinglePlayer) {
    MockServer server = MockServer(JsonSerializer());
    gameRef = Game(connectToMockServer(server, playerId: playerId));
    Ai(connectToMockServer(server, playerId: generateId()));
  } else {
    var con = connectToSocket(
      host: serverHost,
      playerId: playerId,
    );
    gameRef = Game(con);
  }

  runApp(MyApp(gameRef));
}

class MyApp extends StatelessWidget {
  final Game gameRef;

  const MyApp(this.gameRef, {Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Battle Ship',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Scaffold(
        body: GameWidget(gameRef),
      ),
    );
  }
}

class GameWidget extends StatelessWidget {
  final Game gameRef;

  const GameWidget(this.gameRef, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<Game>.value(
      value: gameRef,
      builder: (context, child) =>
          Consumer<Game>(builder: (context, gameRef, child) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DebugWidget(gameRef),
            Column(
              children: [
                if (gameRef.phase == Phase.position ||
                    gameRef.phase == Phase.attack)
                  PlayerBoardWidget(gameRef),
                if (gameRef.phase == Phase.attack) EnemyBoardWidget(gameRef),
              ],
            ),
          ],
        );
      }),
    );
  }
}

class DebugWidget extends StatelessWidget {
  final Game gameRef;

  const DebugWidget(this.gameRef, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 600,
      padding: const EdgeInsets.only(left: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            """
Phase: ${gameRef.phase.toString()}
is Your turn? ${gameRef.isPlayerTurn}
Your Id: $playerId
""",
          ),
          SizedBox(
            height: 500,
            width: 300,
            child: Stack(
              children: [
                Positioned(
                  bottom: 0,
                  child: SizedBox(
                    width: 300,
                    child: Text(
                      gameRef.history.map((e) => e.toJson()).join("\n"),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
