import 'package:http/http.dart' as http;
import 'dart:convert';

class LockService {
  final String baseUrl = 'https://ueapi.ttlock.com';

  Future<List> getLocks(String token) async {
    final url = Uri.parse(
      '$baseUrl/v3/lock/list?accessToken=$token&pageNo=1&pageSize=20',
    );

    final response = await http.get(url);
    if(response.statusCode == 200){
      final data =json.decode(response.body);
      return data ['list'] ?? [];
    } else {
      print(response.body);
      return [];
    }
  }
}