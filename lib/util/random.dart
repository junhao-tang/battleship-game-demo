import 'dart:math';

Random _rand = Random();
String _chars =
    'AaBbCcDdEeFfGgHhIiJjKkLlMmNnOoPpQqRrSsTtUuVvWwXxYyZz1234567890';
const int idSize = 10;

String generateId() =>
    List.generate(idSize, (index) => _chars[_rand.nextInt(_chars.length)])
        .join();

Future<void> randomWait(int randMs, {required int min}) => Future.delayed(
      Duration(milliseconds: _rand.nextInt(randMs) + min),
    );
