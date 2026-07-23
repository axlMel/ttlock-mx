import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/group.dart';
import 'dart:async';

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

        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }

        final data = jsonDecode(response.body);

        if (data.containsKey('errcode') && data['errcode'] != 0) {
          throw Exception('${data['errmsg']} (${data['errcode']})');
        }

        final List groupsJson = data['list'] ?? [];
        return groupsJson.map((json) => Group.fromJson(json)).toList();
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
      if (response.statusCode != 200) {
        throw Exception('HTTP ${response.statusCode}');
      }

      final data = jsonDecode(response.body);

      if (data.containsKey('errcode') && data['errcode'] != 0) {
        throw Exception('${data['errmsg']} (${data['errcode']})');
      }

      return {
        'success': true,
        'groupId': data['groupId'],
      };
    } on TimeoutException {
      throw Exception('No fue posible conectar con el servidor');
    }
    on http.ClientException {
      throw Exception('No fue posible conectar con el servidor');
    }
    catch (e) {
      rethrow;
    }
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
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }
        final data = jsonDecode(response.body);
        if (data.containsKey('errcode') && data['errcode'] != 0) {
          throw Exception('${data['errmsg']} (${data['errcode']})');
        }
        return true;
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
