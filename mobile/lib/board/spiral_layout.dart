/// Proyección visual. No modifica el orden ni las posiciones del motor.
class BoardPoint {
  const BoardPoint(this.column, this.row);
  final int column, row;
  int distanceTo(BoardPoint other) =>
      (column - other.column).abs() + (row - other.row).abs();
  @override
  bool operator ==(Object other) =>
      other is BoardPoint && column == other.column && row == other.row;
  @override
  int get hashCode => Object.hash(column, row);
}

class SpiralLayout {
  SpiralLayout._(this.columns, this.rows, this.path, this.goalCells);
  final int columns, rows;
  final List<BoardPoint> path, goalCells;
  BoardPoint get startMarker => path.first;
  BoardPoint get goalMarker => path.last;
  factory SpiralLayout.forSize(int length) {
    final dimensions = switch (length) {
      30 => (7, 6),
      50 => (8, 8),
      75 => (9, 9),
      100 => (11, 10),
      _ => throw ArgumentError.value(length, 'length'),
    };
    final (columns, rows) = dimensions;
    final cells = <BoardPoint>[];
    var left = 0, right = columns - 1, top = 0, bottom = rows - 1;
    while (left <= right && top <= bottom) {
      for (var x = left; x <= right; x++) {
        cells.add(BoardPoint(x, bottom));
      }
      bottom--;
      for (var y = bottom; y >= top; y--) {
        cells.add(BoardPoint(right, y));
      }
      right--;
      if (top <= bottom) {
        for (var x = right; x >= left; x--) {
          cells.add(BoardPoint(x, top));
        }
        top++;
      }
      if (left <= right) {
        for (var y = top; y <= bottom; y++) {
          cells.add(BoardPoint(left, y));
        }
        left++;
      }
    }
    final List<BoardPoint> route = List.unmodifiable(cells.take(length + 2));
    // La ruta contiene marcador de inicio, N casillas numeradas y meta.
    return SpiralLayout._(
      columns,
      rows,
      route,
      List.unmodifiable([route.last]),
    );
  }
}
