import 'package:demo_battleship/models/sea.dart';
import 'package:flutter/material.dart';

class SeaWidget extends StatelessWidget {
  final Sea sea;
  final void Function(int) callback;

  const SeaWidget(
    this.sea, {
    required this.callback,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      itemCount: sea.data.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: sea.width,
      ),
      itemBuilder: (context, index) => CellWidget(
        callback: () => callback(index),
        fieldType: sea.data[index],
      ),
    );
  }
}

class CellWidget extends StatelessWidget {
  static const Map<FieldType, Color> colors = {
    FieldType.empty: Colors.white,
    FieldType.occupied: Colors.green,
    FieldType.hit: Colors.red,
    FieldType.missed: Colors.blue,
    FieldType.unknown: Colors.grey,
  };
  static const Color defaultColor = Colors.blue;

  final VoidCallback callback;
  final FieldType fieldType;

  const CellWidget({required this.callback, required this.fieldType, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: callback,
      child: Container(
        decoration: BoxDecoration(
          color: colors[fieldType] ?? defaultColor,
          border: Border.all(color: Colors.black),
        ),
      ),
    );
  }
}
