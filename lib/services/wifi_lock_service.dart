import "dart:convert";
import 'package:http/http.dart' as http;
import '../models/wifi_info.dart';
import 'dart:async';

class WifiLockService {
  static const String clientId = '096a5c62f3ae47c39e206d410119d7b3';
  static const String baseUrl = 'https://euapi.ttlock.com';

  Future<WifiInfo> getWifiDetails(String token, int lockId) async {
    final url = Uri.parse('$baseUrl/v3/wifiLock/detail');
    final date = DateTime.now().millisecondsSinceEpoch;
    print('OBTENIENDO WIFI INFO');
    print('LOCK ID: $lockId');
    for (int i = 0; i < 6; i++) {
      try {
        final response = await http
            .post(
              url,
              body: {
                'clientId': clientId,
                'accessToken': token,
                'lockId': lockId.toString(),
                'date': date.toString(),
              },
            )
            .timeout(const Duration(seconds: 45));
        print('WIFI STATUS: ${response.statusCode}');
        print('WIFI BODY: ${response.body}');

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }
        final data = jsonDecode(response.body);
        if (data.containsKey('errcode') && data['errcode'] != 0) {
          throw Exception('${data['errmsg']} (${data['errcode']})');
        }
        return WifiInfo.fromJson(data);
      } on TimeoutException {
        print('Timeout intento ${i + 1}');
      }
      on http.ClientException {
        print('Error de conexión intento ${i + 1}');
      }
      catch (e) {
        rethrow;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    throw Exception('No fue posible conectar con el servidor');
  }

  Future<void> unlock(String token, int lockId) async {
    final url = Uri.parse('$baseUrl/v3/lock/unlock');
    final date = DateTime.now().millisecondsSinceEpoch;
    print('OBTENIENDO WIFI INFO');
    print('LOCK ID: $lockId');
    for (var i = 0; i < 6; i++) {
      try {
        final response = await http
            .post(
              url,
              body: {
                'clientId': clientId,
                'accessToken': token,
                'lockId': lockId.toString(),
                'date': date.toString(),
              },
            )
            .timeout(const Duration(seconds: 30));
        print('UNLOCK STATUS: ${response.statusCode}');
        print('UNLOCK BODY: ${response.body}');
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }

        final data = jsonDecode(response.body);

        if (data.containsKey('errcode') && data['errcode'] != 0) {
          throw Exception('${data['errmsg']} (${data['errcode']})');
        }

        return;
      } on TimeoutException {
        print('Timeout intento ${i + 1}');
      }
      on http.ClientException {
        print('Error de conexión intento ${i + 1}');
      }
      catch (e) {
        rethrow;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    throw Exception('No fue posible conectar con el servidor');
  }
}
