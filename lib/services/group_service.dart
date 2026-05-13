import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/group.dart';

class GroupService {
  final String baseUrl = 'https://euapi.ttlock.com';

  Future<List<Group>> getGroups(String token) async {
    print("INICIADNO REQUEST GRUPOS");
    final date = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
      '$baseUrl/v3/group/list'
      '?clientId=096a5c62f3ae47c39e206d410119d7b3'
      '&accessToken=$token'
      '&pageNo=1'
      '&pageSize=100'
      '&date=$date',
    );

    print('OBTENIENDO GRUPOS');
    print(url);

    for (int i = 0; i < 3; i++) {
      try {
        final response = await http.get(url).timeout(const Duration(seconds: 100));

        print('GROUP STATUS: ${response.statusCode}');
        print('GROUP BODY: ${response.body}');

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          final List groupsJson = data['list'] ?? [];
          return groupsJson.map((json) => Group.fromJson(json)).toList();
        } 
      } catch (e) {
        print('Intento groups ${i + 1} falló: $e');
      }
      await Future.delayed(
        const Duration(seconds: 2),
      );
    }
    return [];
  }
}