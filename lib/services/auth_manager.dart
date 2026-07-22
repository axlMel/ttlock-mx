import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:api_app/models/ekey.dart';
import 'package:api_app/models/group.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class AuthManager {
  static const FlutterSecureStorage storage = FlutterSecureStorage();
  static const String tokenKey = 'access_token';
  static const String eKeysKey = 'ekeys';
  static const String groupsKey = 'groups';
  static String? currentToken;
  static List<EKey> eKeys = [];
  static List<Group> groups = [];
  // Guardar token
  static Future<void> saveToken(String token) async {
    currentToken = token;
    await storage.write(key: tokenKey, value: token);
    print('TOKEN GUARDADO');
  }

  // Leer token
  static Future<String?> getToken() async {
    currentToken ??= await storage.read(key: tokenKey);
    print('TOKEN LEÍDO: $currentToken');
    return currentToken;
  }

  // Ekeys
  static Future<void> saveEKeys(List<EKey> keys) async {
    eKeys = keys;
    final prefs = await SharedPreferences.getInstance();
    final jsonList = keys
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    await prefs.setStringList(eKeysKey, jsonList);
    print('AUTH EKEYS: ${keys.length}');
  }

  static Future<List<EKey>> getEKeys() async {
    if (eKeys.isNotEmpty) {
      return eKeys;
    }
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(eKeysKey);
    if (list == null) {
      return [];
    }
    eKeys = list
        .map((e) => EKey.fromJson(jsonDecode(e)))
        .toList();
    print('AUTH EKEYS: ${eKeys.length}');
    return eKeys;
  }

  // Groups
  static Future<void> saveGroups(List<Group> newGroups) async {
    groups = newGroups;
    final prefs = await SharedPreferences.getInstance();
    final jsonList = newGroups
        .map((e) => jsonEncode(e.toJson()))
        .toList();
    await prefs.setStringList(groupsKey, jsonList);
    print('AUTH GROUPS: ${groups.length}');
  }

  static Future<List<Group>> getGroups() async {
    if (groups.isNotEmpty) {
      return groups;
    }
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(groupsKey);
    if (list == null) {
      return [];
    }
    groups = list
        .map((e) => Group.fromJson(jsonDecode(e)))
        .toList();
    print('AUTH GROUPS: ${groups.length}');
    return groups;
  }

  // Eliminar token
  static Future<void> logout() async {
    currentToken = null;
    eKeys.clear();
    groups.clear();
    await storage.delete(key: tokenKey);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(eKeysKey);
    await prefs.remove(groupsKey);
    print('TOKEN ELIMINADO');
  }
}
