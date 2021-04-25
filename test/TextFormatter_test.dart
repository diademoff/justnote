import 'package:flutter_test/flutter_test.dart';
import 'package:justnote/textFormatter.dart';

void main() {
  test('TextFormatter remove blank lines test', () async {
    var tests = [
      ["\n\t\t\n\t", ""],
      ["\n\t\t\n\t ", " "],
      ["\n\t \t\n\t", " "],
      ["\n \t \t \n \t", " "],
      ["t\n\t\t\t\t\t\t\t\n", "t"],
      ["test1\t test2\t tst\n", "test1\t test2\t tst"],
      ["  ", " "],
      ["                   \n", " "],
      ["Paragraph\nnew line \n \n \t \n", "Paragraph\nnew line "],
      ["1. line\n2.line\nline\n", "1. line\n2.line\nline"],
      ["1. line\n2. line", "1. line\n2. line"]
    ];

    for (var test in tests) {
      var input = test[0];
      var outputExpected = test[1];

      var formatter = TextFormatter(input);
      formatter.removeWhiteLines();

      expect(formatter.formattedText, outputExpected);
    }
  });

  test('TextFormatter remove blank and add next number', () async {
    var tests = [
      ["", "1. "],
      ["98. line", "98. line\n99. "],
      ["98. line\n99. ", "98. line\n99. "],
      ["98. line\n99. new line", "98. line\n99. new line\n100. "],
      ["1. first", "1. first\n2. "],
      ["1. first\n2. second\nsecond too", "1. first\n2. second\nsecond too\n3. "]
    ];

    for (var test in tests) {
      var input = test[0];
      var outputExpected = test[1];

      var formatter = TextFormatter(input);
      formatter.removeWhiteLines();
      if (!formatter.isNumberAdded()) {
        formatter.addNumber();
      }

      expect(formatter.formattedText, outputExpected);
    }
  });

  test('TextFormatter insert tag test', () async {
    var tests = [
      ['', 0, 0, '<b>', '</b>', '<b></b>', 3],
      ['test', 0, 4, '<b>', '</b>', '<b>test</b>', 7],
      ['test', 1, 2, '<u>', '</u>', 't<u>e</u>st', 5]
    ];

    for (var test in tests) {
      var input = test[0];
      var startIndex = test[1];
      var endIndex = test[2];
      var tagOpen = test[3];
      var tagClose = test[4];
      var output = test[5];
      var indexMustBe = test[6];

      var formatter = TextFormatter(input);

      var i = formatter.insertTag(startIndex, endIndex, tagOpen, tagClose);

      expect(formatter.formattedText, output);
      expect(i, indexMustBe);
    }
  });
}
