import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:api_app/models/ekey.dart';
import 'package:api_app/models/group.dart';

class AuthManager {
  static const FlutterSecureStorage storage = FlutterSecureStorage();
  static const String tokenKey = 'access_token';
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
  static void setEKeys(List<EKey> keys) {
    eKeys = keys;
  }

  static List<EKey> getEKeys() {
    return eKeys;
  }

  // Groups
  static void setGroups(List<Group> newGroups) {
    groups = newGroups;
  }

  static List<Group> getGroups() {
    return groups;
  }

  // Eliminar token
  static Future<void> logout() async {
    currentToken = null;
    eKeys.clear();
    groups.clear();
    await storage.delete(key: tokenKey);
    print('TOKEN ELIMINADO');
  }
}
