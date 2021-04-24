import 'package:flutter/material.dart';
import 'package:justnote/TextFormatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String appName = "Just Note";

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
  FocusNode _focusNode = FocusNode(); // used for showing keyboard
  bool isKeyboardShowing() => MediaQuery.of(context).viewInsets.vertical > 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // call this function after build is complete
      showKeyboard();
    });
  }

  bool _firstBuild = true;
  @override
  Widget build(BuildContext context) {
    // This condition is met on first build.
    if (_firstBuild) {
      _firstBuild = false;
      loadStoredData();
    }

    return MaterialApp(
      title: appName,
      theme: isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: Scaffold(
        appBar: getAppBar(),
        body: Container(
          alignment: Alignment.topCenter,
          constraints: BoxConstraints.expand(),
          child: TextField(
            focusNode: _focusNode,
            autofocus: true,
            style: TextStyle(
                fontSize: 18.0, fontFamily: getFontFamily(isTextHidden)),
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
        icon: isTextHidden ? Icon(Icons.security) : Icon(Icons.group),
        onPressed: () {
          setState(() {
            isTextHidden = !isTextHidden;
          });
        },
      ),
      title: Text(appName),
      actions: [
        IconButton(
            icon: isDarkTheme ? Icon(Icons.wb_sunny) : Icon(Icons.brightness_2),
            onPressed: () {
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
              showKeyboard();
            });
          },
        )
      ],
    );
  }

  /// Get text font depending on whether you
  /// want to make the text visible
  String getFontFamily(bool isTextHidden) {
    if (isTextHidden) {
      // custom application font to hide symbols
      // it is modified "Roboto-regular" font
      return "hidden";
    } else {
      return "roboto";
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
      setCursorToEnd();
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

  void showKeyboard() {
    if (!isKeyboardShowing()) {
      FocusScope.of(context).requestFocus(_focusNode);
    }
  }
}
