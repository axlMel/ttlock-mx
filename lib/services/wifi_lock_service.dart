import "dart:convert";
import 'package:http/http.dart' as http;
import '../models/wifi_info.dart';

class WifiLockService {
  static const String clientId = '096a5c62f3ae47c39e206d410119d7b3';
  static const String baseUrl = 'https://euapi.ttlock.com';

  Future<WifiInfo?> getWifiDetails(String token, int lockId) async {
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

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['errcode'] != null && data['errcode'] != 0) {
            return null;
          }
          return WifiInfo.fromJson(data);
        }
      } catch (e) {
        print('Intento wifi ${i + 1} fallo: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return null;
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
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['errcode'] != 0) {
            throw Exception(data['errmsg']);
          }
          return;
        }
        throw Exception('HTTP ${response.statusCode}');
      } catch (e) {
        print('Intento wifi ${i + 1} fallo: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return;
  }
}
