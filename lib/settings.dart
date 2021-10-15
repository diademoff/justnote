import 'package:shared_preferences/shared_preferences.dart';

class UserSettings {
  static bool isDarkTheme = false;
  static String text = "";

  /// * Retrieve the text stored in memory and write it to the text field.
  /// * Gets if the dark theme is used
  static void Load(SharedPreferences prefs) {
    isDarkTheme = prefs.getBool('is_dark_theme') ?? false;
    text = prefs.getString('text') ?? "";
  }

  /// Save the content of text field to memeory
  static void Save(SharedPreferences prefs) {
    prefs.setString('text', text);
    prefs.setBool('is_dark_theme', isDarkTheme);
  }
}
