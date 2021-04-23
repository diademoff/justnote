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
  bool isDarkTheme = false;
  TextEditingController textFieldController = new TextEditingController();

  bool _firstBuild = true;
  @override
  Widget build(BuildContext context) {
    // This condition is met on first build.
    if (_firstBuild) {
      _firstBuild = false;
      loadStoredData();
    }

    return MaterialApp(
      theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
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
            onChanged: (s) => {saveDataToStorage()},
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
          icon: isDarkTheme ? Icon(Icons.wb_sunny) : Icon(Icons.brightness_2) , 
          onPressed: (){
            setState(() {
              isDarkTheme = !isDarkTheme;
              saveDataToStorage();
            });
          }),
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
      if (isDarkTheme) {
        return Colors.grey[850];
      } else {
        return Colors.white;
      }
    } else {
      if (isDarkTheme) {
        return Colors.white;
      } else {
        return Colors.black87;
      }
    }
  }

  /// Save the content of text field to memeory
  void saveDataToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    prefs.setString('text', textFieldController.text);
    prefs.setBool('is_dark_theme', isDarkTheme);
  }

  /// * Retrieve the text stored in memory and write it to the text field.
  /// * Gets if the dark theme is used
  void loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();

    textFieldController.text = prefs.getString('text') ?? "";

    setState(() {
      isDarkTheme = prefs.getBool('is_dark_theme') ?? false;
    });
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
