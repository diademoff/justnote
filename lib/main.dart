import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:justnote/textFormatter.dart';
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
  bool htmlViewmode = false;

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

    var appTheme = ThemeData(
        brightness: isDarkTheme ? Brightness.dark : Brightness.light,
        primaryColor: isDarkTheme ? Colors.black : Colors.white,
        accentColor: isDarkTheme ? Colors.white54 : Colors.black54);

    return MaterialApp(
      title: appName,
      theme: appTheme,
      home: Scaffold(
        appBar: getAppBar(),
        body: Container(
            alignment: Alignment.topCenter,
            constraints: BoxConstraints.expand(),
            child: Column(
              children: [
                Expanded(
                    child: SingleChildScrollView(
                        child: htmlViewmode ? getHtml() : getTextField())),
                Container(
                    child:
                        htmlViewmode ? SizedBox() : getTextFormatingActions()),
              ],
            )),
      ),
    );
  }

  /// Format actions panel
  /// * bold
  /// * italic
  /// * underlined
  Row getTextFormatingActions() {
    double iconSize = 24;
    double interval = 5;
    return Row(
      children: [
        InkWell(
            child: Icon(Icons.format_bold, size: iconSize),
            onTap: () => setFormat('<b>', '</b>')),
        SizedBox(width: interval),
        InkWell(
            child: Icon(Icons.format_italic, size: iconSize),
            onTap: () => setFormat('<i>', '</i>')),
        SizedBox(width: interval),
        InkWell(
            child: Icon(Icons.format_underline, size: iconSize),
            onTap: () => setFormat('<u>', '</u>')),
        Expanded(
            child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [getViewModeSwitchIconButton()]))
      ],
    );
  }

  /// Iconbutton to switch between html view mode and text mode
  /// onPressed: `htmlViewmode = !htmlViewmode;`
  IconButton getViewModeSwitchIconButton() {
    return IconButton(
        icon: htmlViewmode ? Icon(Icons.text_format) : Icon(Icons.web_sharp),
        onPressed: () {
          setState(() {
            htmlViewmode = !htmlViewmode;
          });
        });
  }

  void setFormat(String tag, String closeTag) {
    TextFormatter tf = TextFormatter(textFieldController.text);

    int startIndex = textFieldController.selection.baseOffset;
    int endIndex = textFieldController.selection.extentOffset;

    int cursorPos = tf.insertTag(startIndex, endIndex, tag, closeTag);

    textFieldController.text = tf.formattedText;

    // set correct cursor position
    textFieldController.selection =
        TextSelection.fromPosition(TextPosition(offset: cursorPos));
  }

  Html getHtml() {
    return Html(data: convertToHtml(textFieldController.text));
  }

  String convertToHtml(String input) {
    String html = '';

    for (var i = 0; i < input.length; i++) {
      if (input[i] == '\n') {
        html += '<br>';
        continue;
      }
      html += input[i];
    }
    return html;
  }

  TextField getTextField() {
    return TextField(
      focusNode: _focusNode,
      autofocus: true,
      style: TextStyle(fontSize: 18.0, fontFamily: getFontFamily(isTextHidden)),
      maxLines: null,
      keyboardType: TextInputType.multiline,
      controller: textFieldController,
      onChanged: (s) => {saveDataToStorage()},
    );
  }

  /// The top line of the application with buttons.
  AppBar getAppBar() {
    return AppBar(
      leading: htmlViewmode
          ? getViewModeSwitchIconButton()
          : IconButton(
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
        htmlViewmode
            ? SizedBox()
            : IconButton(
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
