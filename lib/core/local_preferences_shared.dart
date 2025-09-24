import 'package:shared_preferences/shared_preferences.dart';
import 'i_local_preferences.dart';

// ✅ Clase corregida
class LocalPreferencesShared implements ILocalPreferences {
  late SharedPreferences _prefs;

  // ✅ Constructor privado
  LocalPreferencesShared._();

  // ✅ Constructor de fábrica asíncrono para inicializar
  static Future<LocalPreferencesShared> init() async {
    final instance = LocalPreferencesShared._();
    instance._prefs = await SharedPreferences.getInstance();
    return instance;
  }

  @override
  Future<T?> retrieveData<T>(String key) async {
    dynamic value;
    if (T == bool) {
      value = _prefs.getBool(key);
    } else if (T == double) {
      value = _prefs.getDouble(key);
    } else if (T == int) {
      value = _prefs.getInt(key);
    } else if (T == String) {
      value = _prefs.getString(key);
    } else if (T == List<String>) {
      value = _prefs.getStringList(key);
    }
    return value as T?;
  }

  @override
  Future<void> storeData(String key, dynamic value) async {
    if (value is bool) {
      await _prefs.setBool(key, value);
    } else if (value is double) {
      await _prefs.setDouble(key, value);
    } else if (value is int) {
      await _prefs.setInt(key, value);
    } else if (value is String) {
      await _prefs.setString(key, value);
    } else if (value is List<String>) {
      await _prefs.setStringList(key, value);
    } else {
      throw Exception("Unsupported type");
    }
  }

  @override
  Future<void> removeData(String key) async => await _prefs.remove(key);

  @override
  Future<void> clearAll() async => await _prefs.clear();
}