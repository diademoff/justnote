class TextFormatter {
  String _text;
  String get formattedText => _text;

  TextFormatter(this._text);

  /// Removes white lines
  /// If there are a lot of spaces, then only one will be left
  void removeWhiteLines() {
    int countOfUnnecessaryChars = 0;
    bool wasSpace = false;
    for (int i = _text.length - 1; i >= 0; i--) {
      if (_text[i] == ' ' || _text[i] == '\n' || _text[i] == '\t') {
        countOfUnnecessaryChars += 1;
      } else {
        break;
      }

      if (_text[i] == ' ') {
        wasSpace = true;
      }
    }

    _text = _text.substring(0, _text.length - countOfUnnecessaryChars);
    _text += wasSpace ? " " : "";
  }

  bool isNumberAdded() {
    var lines = _text.split('\n');
    var lastLine = lines[lines.length - 1];
    if (lastLine.trim().contains('.')) {
      var number = int.tryParse(lastLine.split('.')[0]);
      if (number != null && lastLine.split('.')[1].trim().isEmpty) {
        return true;
      }
    }

    return false;
  }

  void addNumber() {
    int nextNum = _getNextNum();
    String newLine = needNewLine() ? "\n" : "";
    _text += "$newLine$nextNum. ";
  }

  int _getNextNum() {
    if (_text.trim().isEmpty) {
      return 1;
    }

    var lines = _text.split('\n');

    for (int i = lines.length - 1; i >= 0; i--) {
      var currentLine = lines[i];
      if (currentLine.contains('.')) {
        int number = int.tryParse(currentLine.split('.')[0].trim());
        if (number != null) {
          return number + 1;
        }
      }
    }

    return 1;
  }

  bool needNewLine() {
    if (_text.trim().isEmpty) {
      return false;
    }

    var lines = _text.split('\n');
    var lastLine = lines[lines.length - 1];

    if (lastLine.trim().isNotEmpty) {
      return true;
    }
    return false;
  }
}
