import 'package:flutter_test/flutter_test.dart';
import 'package:justnote/TextFormatter.dart';

void main() {
  test('TextFormatter test', () async {
    var tests = [
      
      ["\n\t\t\n\t", ""],
      ["\n\t\t\n\t ", " "],
      ["\n\t \t\n\t", " "],
      ["\n \t \t \n \t", " "],
      ["t\n\t\t\t\t\t\t\t\n", "t"],
      ["test1\t test2\t tst\n", "test1\t test2\t tst"],
      ["  ", " "],
      ["                   \n", " "],
    ];

    for (var test in tests) {
      var input = test[0];
      var outputExpected = test[1];

      var formatter = TextFormatter(input);
      formatter.removeWhiteLines();

      expect(formatter.formattedText, outputExpected);
    }
  });
}
