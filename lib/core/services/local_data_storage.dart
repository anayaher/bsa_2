import 'package:shared_preferences/shared_preferences.dart';

class LocalStorageService {
  static const String keyPassword = "user_password";

  /// Save password
  static Future<void> savePassword(String pass) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(keyPassword, pass);
  }

  /// Get saved password
  static Future<String?> getPassword() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(keyPassword);
  }

  /// Check if password matches
  static Future<bool> validatePassword(String entered) async {
    final saved = await getPassword();
    return saved == entered;
  }
}
