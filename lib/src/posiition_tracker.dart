class PositionTracker {
  final String text;
  final Map<int, int> _lineOffsets = {};

  PositionTracker(this.text) {
    int line = 1;
    _lineOffsets[line] = 0; // line 1 starts at offset 0

    for (int i = 0; i < text.length; i++) {
      if (text.codeUnitAt(i) == 10) { // '\n'
        line++;
        _lineOffsets[line] = i + 1; // next line starts after '\n'
      }
    }
  }

  /// Returns [line, column] for a given offset
  List<int> lineColumnAt(int offset) {
    if (offset < 0) offset = 0;
    if (offset > text.length) offset = text.length;

    // Find the greatest line whose start <= offset
    int line = 1;
    for (final entry in _lineOffsets.entries) {
      if (entry.value <= offset) {
        line = entry.key;
      } else {
        break;
      }
    }

    final column = offset - (_lineOffsets[line] ?? 0) ;
    return [line, column];
  }
}
