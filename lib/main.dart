import 'package:flutter/material.dart';
import 'package:justnote/TextFormatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(App());
}

class App extends StatefulWidget {
  @override
  _App createState() => _App();
}

class _App extends State<App> {
  bool isTextHidden = true;
  TextEditingController textFieldController = new TextEditingController();

  bool _firstBuild = true;
  @override
  Widget build(BuildContext context) {
    // This condition is met on first build.
    if (_firstBuild) {
      _firstBuild = false;
      loadTextField();
    }

    return MaterialApp(
      home: Scaffold(
        appBar: getAppBar(),
        body: Container(
          alignment: Alignment.topCenter,
          constraints: BoxConstraints.expand(),
          child: TextField(
            autofocus: true,
            style: TextStyle(fontSize: 18.0, color: getTextColor(isTextHidden)),
            maxLines: null,
            keyboardType: TextInputType.multiline,
            controller: textFieldController,
            onChanged: (s) => {saveTextField()},
          ),
        ),
      ),
    );
  }

  /// The top line of the application with buttons.
  AppBar getAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.add_a_photo),
        onPressed: () {
          setState(() {
            isTextHidden = !isTextHidden;
          });
        },
      ),
      title: Text("Just Note"),
      actions: [
        IconButton(
          icon: Icon(Icons.accessible_forward),
          onPressed: () {
            setState(() {
              addNumberToTextField();
            });
          },
        )
      ],
    );
  }

  /// Get text field foreground color depending on whether you
  /// want to make the text visible
  Color getTextColor(bool isTextHidden) {
    if (isTextHidden) {
      return Colors.white;
    } else {
      return Colors.black87;
    }
  }

  /// Save the content of text field to memeory
  void saveTextField() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'text';
    final value = textFieldController.text;

    prefs.setString(key, value);
  }

  /// Retrieve the text stored in memory and write it to the text field.
  void loadTextField() async {
    final prefs = await SharedPreferences.getInstance();
    final key = 'text';

    textFieldController.text = prefs.getString(key) ?? "";
  }

  /// Remove blank lines and add the next consecutive number at the end of the text box
  void addNumberToTextField() {
    var formatter = TextFormatter(textFieldController.text);

    formatter.removeWhiteLines();
    if (!formatter.isNumberAdded()) {
      formatter.addNumber();
    }

    textFieldController.text = formatter.formattedText;
    setCursorToEnd();
  }

  void setCursorToEnd() {
    textFieldController.selection = TextSelection.fromPosition(
        TextPosition(offset: textFieldController.text.length));
  }
}
