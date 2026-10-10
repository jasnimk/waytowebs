import 'package:shared_preferences/shared_preferences.dart';
import '../../core/utils/logger.dart';

class StorageService {
  static StorageService? _instance;
  static SharedPreferences? _preferences;

  StorageService._internal();

  static StorageService get instance {
    _instance ??= StorageService._internal();
    return _instance!;
  }

  static Future<void> init() async {
    try {
      _preferences = await SharedPreferences.getInstance();
      AppLogger.success('Storage service initialized');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to initialize storage', e, stackTrace);
      rethrow;
    }
  }

  // String
  Future<bool> setString(String key, String value) async {
    try {
      return await _preferences!.setString(key, value);
    } catch (e) {
      AppLogger.error('Error saving string: $key', e);
      return false;
    }
  }

  String? getString(String key) {
    try {
      return _preferences!.getString(key);
    } catch (e) {
      AppLogger.error('Error getting string: $key', e);
      return null;
    }
  }

  // Int
  Future<bool> setInt(String key, int value) async {
    try {
      return await _preferences!.setInt(key, value);
    } catch (e) {
      AppLogger.error('Error saving int: $key', e);
      return false;
    }
  }

  int? getInt(String key) {
    try {
      return _preferences!.getInt(key);
    } catch (e) {
      AppLogger.error('Error getting int: $key', e);
      return null;
    }
  }

  // Bool
  Future<bool> setBool(String key, bool value) async {
    try {
      return await _preferences!.setBool(key, value);
    } catch (e) {
      AppLogger.error('Error saving bool: $key', e);
      return false;
    }
  }

  bool? getBool(String key) {
    try {
      return _preferences!.getBool(key);
    } catch (e) {
      AppLogger.error('Error getting bool: $key', e);
      return null;
    }
  }

  // Double
  Future<bool> setDouble(String key, double value) async {
    try {
      return await _preferences!.setDouble(key, value);
    } catch (e) {
      AppLogger.error('Error saving double: $key', e);
      return false;
    }
  }

  double? getDouble(String key) {
    try {
      return _preferences!.getDouble(key);
    } catch (e) {
      AppLogger.error('Error getting double: $key', e);
      return null;
    }
  }

  // List<String>
  Future<bool> setStringList(String key, List<String> value) async {
    try {
      return await _preferences!.setStringList(key, value);
    } catch (e) {
      AppLogger.error('Error saving string list: $key', e);
      return false;
    }
  }

  List<String>? getStringList(String key) {
    try {
      return _preferences!.getStringList(key);
    } catch (e) {
      AppLogger.error('Error getting string list: $key', e);
      return null;
    }
  }

  // Remove
  Future<bool> remove(String key) async {
    try {
      return await _preferences!.remove(key);
    } catch (e) {
      AppLogger.error('Error removing key: $key', e);
      return false;
    }
  }

  // Clear all
  Future<bool> clear() async {
    try {
      return await _preferences!.clear();
    } catch (e) {
      AppLogger.error('Error clearing storage', e);
      return false;
    }
  }

  // Check if key exists
  bool containsKey(String key) {
    try {
      return _preferences!.containsKey(key);
    } catch (e) {
      AppLogger.error('Error checking key: $key', e);
      return false;
    }
  }
}
