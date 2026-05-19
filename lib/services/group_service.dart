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

    for (int i = 0; i < 6; i++) {
      try {
        final response = await http
            .get(url)
            .timeout(const Duration(seconds: 45));

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
      await Future.delayed(const Duration(seconds: 2));
    }
    return [];
  }

  Future<Map<String, dynamic>> createGroup(
    String token,
    String groupName,
  ) async {
    final date = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse('$baseUrl/v3/group/add');
    print('CREANDO GRUPO');
    print(url);

    try {
      final response = await http
          .post(
            url,
            body: {
              'clientId': '096a5c62f3ae47c39e206d410119d7b3',
              'accessToken': token,
              'name': groupName,
              'date': date.toString(),
            },
          )
          .timeout(const Duration(seconds: 45));
      print('CREATE GROUP STATUS: ${response.statusCode}');
      print('CREATE GROUP BODY: ${response.body}');
      print('CREATE GROUP NAME: ${groupName}');
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['errcode'] != null) {
          return {'success': false, 'message': data['errmsg']};
        }

        return {'success': true, 'groupId': data['groupId']};
      }
    } catch (e) {
      print('ERROR CREANDO GRUPO: $e');

      return {'success': false, 'message': 'Error de conexión'};
    }

    return {'success': false, 'message': 'No se pudo conectar'};
  }

  Future<bool> setLockGroup(String token, int lockId, int groupId) async {
    final date = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse('$baseUrl/v3/lock/setGroup');
    print('Moviendo chapa a grupo');
    print(url);

    for (int i = 0; i < 5; i++) {
      try {
        final response = await http
            .post(
              url,
              body: {
                'clientId': '096a5c62f3ae47c39e206d410119d7b3',
                'accessToken': token,
                'lockId': lockId.toString(),
                'groupId': groupId.toString(),
                'date': date.toString(),
              },
            )
            .timeout(const Duration(seconds: 45));
        print('Status de grupo seteado: ${response.statusCode}');
        print('Cuerpo de grupo seteado: ${response.body}');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['errcode'] == 0;
        }
      } catch (e) {
        print('Error moviendo chapa: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return false;
  }
}
