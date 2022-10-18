enum FieldType {
  empty,
  unknown,
  hit,
  missed,
  occupied,
}

class Sea {
  final int width;
  final int height;

  late final List<FieldType> data;

  Sea.player(this.width, this.height) {
    data = List<FieldType>.filled(width * height, FieldType.empty);
  }

  Sea.enemy(this.width, this.height) {
    data = List<FieldType>.filled(width * height, FieldType.unknown);
  }

  List<int> toIndices(int index, int shipWidth, int shipHeight) {
    return List<int>.generate(
      shipWidth * shipHeight,
      (i) {
        var row = i ~/ shipWidth;
        var col = i % shipWidth;
        return index + col + row * width;
      },
    );
  }

  bool canPut(
    int index,
    int shipWidth,
    int shipHeight,
  ) {
    if (index ~/ width + shipHeight > height) return false;
    if (index % width + shipWidth > width) return false;
    return toIndices(
      index,
      shipWidth,
      shipHeight,
    ).every((i) => data[i] == FieldType.empty);
  }

  void put(
    int index,
    int shipWidth,
    int shipHeight,
  ) {
    var indices = toIndices(
      index,
      shipWidth,
      shipHeight,
    );
    for (int i in indices) {
      data[i] = FieldType.occupied;
    }
  }

  bool canAttack(int index) => data[index] == FieldType.unknown;
  bool canAttacked(int index) =>
      data[index] == FieldType.empty || data[index] == FieldType.occupied;
  bool isOccupied(int index) {
    if (data[index] == FieldType.occupied) return true;
    return false;
  }

  void set(int index, FieldType type) => data[index] = type;
}
