import 'package:flutter/material.dart';
import 'package:justnote/settings.dart';
import 'package:justnote/textFormatter.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String appName = "Just Note";

void main() {
  runApp(MyMaterialApp());
}

class MyMaterialApp extends StatefulWidget {
  @override
  _MyMaterialAppState createState() => _MyMaterialAppState();
}

class _MyMaterialAppState extends State<MyMaterialApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      theme: UserSettings.isDarkTheme ? ThemeData.dark() : ThemeData.light(),
      home: App(RefreshUI),
    );
  }

  void RefreshUI() {
    setState(() {});
  }
}

class App extends StatefulWidget {
  Function _refreshParent;

  App(this._refreshParent);

  @override
  _App createState() => _App(_refreshParent);
}

class _App extends State<App> {
  bool isTextHidden = true;

  Function _refreshParent;

  _App(this._refreshParent);

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

  bool _firstStart = true;
  @override
  Widget build(BuildContext context) {
    // This condition is met on first start.
    if (_firstStart) {
      _firstStart = false;
      loadStoredData();
    }

    return Scaffold(
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
            icon: UserSettings.isDarkTheme
                ? Icon(Icons.wb_sunny)
                : Icon(Icons.brightness_2),
            onPressed: () {
              setState(() {
                UserSettings.isDarkTheme = !UserSettings.isDarkTheme;
                refreshUI();
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

  void saveDataToStorage() async {
    final prefs = await SharedPreferences.getInstance();

    UserSettings.text = textFieldController.text;

    UserSettings.Save(prefs);
  }

  void loadStoredData() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      UserSettings.Load(prefs);
      textFieldController.text = UserSettings.text;
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

  void refreshUI() {
    setState(() {
      _refreshParent.call();
    });
  }
}
