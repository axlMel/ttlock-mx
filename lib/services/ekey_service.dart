import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:api_app/models/ekey.dart';

class EKeyService {
  static const String clientId ='096a5c62f3ae47c39e206d410119d7b3';
  static const String baseUrl = 'https://euapi.ttlock.com';

  Future<List<EKey>> getEKeys(String token,) async {
    final now = DateTime.now().millisecondsSinceEpoch;

    final url = Uri.parse(
      '$baseUrl/v3/key/list'
      '?clientId=$clientId'
      '&accessToken=$token'
      '&pageNo=1'
      '&pageSize=100'
      '&date=$now',
    );

    print("OBTENIENDO EKEYS");
    print(url);

    for (var i = 0; i < 6; i++) {
      try {
        final response = await http.get(url).timeout(const Duration(seconds: 45));
        print("EKEY STATUS: ${response.statusCode}");
        print("EKEY BODY: ${response.body}");
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List keysJson = data['list'] ?? [];
          return keysJson.map((e) => EKey.fromJson(e)).toList();
        }
      } catch (e) {
        print('Intento Ekey ${i + 1} falló: $e');
      }
      await Future.delayed(
        const Duration(seconds: 2),
      );
    }
    return [];
  }
}