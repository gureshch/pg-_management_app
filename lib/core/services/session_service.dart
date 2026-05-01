import 'package:shared_preferences/shared_preferences.dart';

class SessionService {
  static const _keyRole = "role";
  static const _keyPhone = "phone";
  static const _keyName = "name";

  /// SAVE USER
  Future<void> saveUser(Map<String, dynamic> user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyRole, user['role']);
    await prefs.setString(_keyPhone, user['phone']);
    await prefs.setString(_keyName, user['name']);
  }

  /// GET USER
  Future<Map<String, String>?> getUser() async {
    final prefs = await SharedPreferences.getInstance();
    final role = prefs.getString(_keyRole);
    final phone = prefs.getString(_keyPhone);
    final name = prefs.getString(_keyName);

    if (role == null) return null;

    return {
      "role": role,
      "phone": phone ?? "",
      "name": name ?? "",
    };
  }

  /// GET USER ID (phone is used as unique identifier)
  Future<String> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyPhone) ?? "";
  }

  /// GET USER NAME
  Future<String> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyName) ?? "";
  }

  /// LOGOUT
  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }
}