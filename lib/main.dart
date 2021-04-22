import 'package:flutter/material.dart';
import 'package:justnote/TextFormatter.dart';

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

  @override
  Widget build(BuildContext context) {
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
          ),
        ),
      ),
    );
  }

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

  Color getTextColor(bool isTextHidden) {
    if (isTextHidden) {
      return Colors.white;
    } else {
      return Colors.black87;
    }
  }

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
