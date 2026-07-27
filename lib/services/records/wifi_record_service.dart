import 'package:http/http.dart' as http;
import 'dart:async';
import "dart:convert";

import 'package:api_app/models/records/record.dart';

class WifiRecordService {
  static const String clientId = '096a5c62f3ae47c39e206d410119d7b3';
  static const String baseUrl = 'https://euapi.ttlock.com';

  Future<List<Record>> getAllRecords(String token, int lockId) async {
    final date = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
      '$baseUrl/v3/lockRecord/list'
      '?clientId=$clientId'
      '&accessToken=$token'
      '&lockId=$lockId'
      '&pageNo=1'
      '&pageSize=200'
      '&date=$date'
    );
    print('OBTENIENDO REGISTROS');
    for (var i = 0; i < 3; i++) {
      try {
        final response = await http.get(url).timeout(Duration(seconds: 30));
        print('GETCODIGOS STATUS: ${response.statusCode}');
        print('GET BODY: ${response.body}');
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }
        final data = jsonDecode(response.body);
        if (data.containsKey('errcode') && data['errcode'] != 0) {
          throw Exception("${data['errmsg']} (${data['errcode']})");
        }
        final List<dynamic> recordsJson = data['list'] ?? [];
        return recordsJson.map((json) => Record.fromJson(json)).toList();
      } on TimeoutException {
        print('Timeout intento ${i + 1}');
      } on http.ClientException catch (e) {
        print("Error de conexión intento ${i + 1}: $e");
      } catch (e) {
        rethrow;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    throw Exception('No fue posible conectar con el servidor');
  }
}
