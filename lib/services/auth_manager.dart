import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthManager {
  static const FlutterSecureStorage storage = FlutterSecureStorage();

  static const String tokenKey = 'access_token';
  // Guardar token
  static Future<void> saveToken(String token) async {
    await storage.write(key: tokenKey, value: token);
    print('TOKEN GUARDADO');
  }

  // Leer token
  static Future<String?> getToken() async {
    final token = await storage.read(key: tokenKey);
    print('TOKEN LEÍDO: $token');
    return token;
  }

  // Eliminar token
  static Future<void> logout() async {
    await storage.delete(key: tokenKey);
    print('TOKEN ELIMINADO');
  }
}
