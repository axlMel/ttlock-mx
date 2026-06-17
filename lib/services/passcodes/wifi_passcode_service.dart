import "dart:convert";
import 'package:http/http.dart' as http;
import 'package:api_app/models/passcode.dart';
import 'package:api_app/models/passcode_creation_result.dart';

class WifiPasscodeService {
  static const String clientId = '096a5c62f3ae47c39e206d410119d7b3';
  static const String baseUrl = 'https://euapi.ttlock.com';

  Future<List<Passcode>> getAllPasscodes(String token, int lockId) async {
    final date = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
      '$baseUrl/v3/lock/listKeyboardPwd'
      '?clientId=$clientId'
      '&accessToken=$token'
      '&lockId=$lockId'
      '&pageNo=1'
      '&pageSize=100'
      '&orderBy=0'
      '&date=$date',
    );
    print('OBTENIENDO CODIGOS DE ACCESO');
    print('LOCK ID: $lockId');
    for (var i = 0; i < 6; i++) {
      try {
        final response = await http.get(url).timeout(Duration(seconds: 30));
        print('GETCODIGOS STATUS: ${response.statusCode}');
        print('GET BODY: ${response.body}');
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          if (data['errcode'] != null && data['errcode'] != 0) {
            throw Exception(data['errmsg']);
          }
          final List<dynamic> accessCodesJson = data['list'] ?? [];
          return accessCodesJson
              .map((json) => Passcode.fromJson(json))
              .toList();
        }
      } catch (e) {
        print('Intento passcodes ${i + 1} falló: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return [];
  }

  Future<PasscodeCreationResult?> getRandomPasscode(
    String token,
    int lockId,
    int keyboardPwdType,
    String keyboardPwdName,
    int startDate,
    int endDate,
  ) async {
    final url = Uri.parse('$baseUrl/v3/keyboardPwd/get');
    final date = DateTime.now().millisecondsSinceEpoch;
    print('OBTENIENDO CONTRASEÑA ALEATORIA');
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
                'keyboardPwdType': keyboardPwdType.toString(),
                'keyboardPwdName': keyboardPwdName,
                'startDate': startDate.toString(),
                'endDate': endDate.toString(),
                'date': date.toString(),
              },
            )
            .timeout(const Duration(seconds: 30));
        print('UNLOCK STATUS: ${response.statusCode}');
        print('UNLOCK BODY: ${response.body}');

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['errcode'] != null && data['errcode'] != 0) {
            throw Exception(data['errmsg']);
          }
          return PasscodeCreationResult.fromJson(data);
        }
        throw Exception('HTTP ${response.statusCode}');
      } catch (e) {
        print('Intento random passcode ${i + 1} falló: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return null;
  }

  Future<PasscodeCreationResult?> getCustomPasscode(
    String token,
    int lockId,
    int keyboardPwd,
    String keyboardPwdName,
    int keyboardPwdType,
    int startDate,
    int endDate,
  ) async {
    final url = Uri.parse('$baseUrl/v3/keyboardPwd/add');
    final date = DateTime.now().millisecondsSinceEpoch;
    print('OBTENIENDO CONTRASEÑA CUSTOMIZADA');
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
                'keyboardPwd': keyboardPwd.toString(),
                'keyboardPwdName': keyboardPwdName,
                'keyboardPwdType': keyboardPwdType.toString(),
                'startDate': startDate.toString(),
                'endDate': endDate.toString(),
                'addType': '2',
                'date': date.toString(),
              },
            )
            .timeout(const Duration(seconds: 30));
        print('CUSTOM PASSCODE STATUS: ${response.statusCode}');
        print('CUSTOM PASSCODE BODY: ${response.body}');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          if (data['errcode'] != null && data['errcode'] != 0) {
            throw Exception(data['errmsg']);
          }
          return PasscodeCreationResult(
            keyboardPwdId: data['keyboardPwdId'],
            keyboardPwd: keyboardPwd.toString(),
          );
        }
        throw Exception('HTTP ${response.statusCode}');
      } catch (e) {
        print('Intento custom passcode ${i + 1} falló: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return null;
  }

  Future<void> deletePasscode(
    String token,
    int lockId,
    int keyboardPwdId,
  ) async {
    final url = Uri.parse('$baseUrl/v3/keyboardPwd/delete');
    final date = DateTime.now().millisecondsSinceEpoch;
    print('BORRANDO CODIGO');
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
                'keyboardPwdId': keyboardPwdId.toString(),
                'deleteType': '2',
                'date': date.toString(),
              },
            )
            .timeout(const Duration(seconds: 30));
        print('DELETE PASSCODE STATUS: ${response.statusCode}');
        print('DELETE PASSCODE BODY: ${response.body}');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
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

  Future<void> changePasscode(
    String token,
    int lockId,
    int keyboardPwdId,
    String keyboardPwdName,
    int newKeyboardPwd,
    int startDate,
    int endDate,
  ) async {
    final url = Uri.parse('$baseUrl/v3/keyboardPwd/change');
    final date = DateTime.now().millisecondsSinceEpoch;
    print('CAMBIANDO PASS');
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
                'keyboardPwdId': keyboardPwdId.toString(),
                'keyboardPwdName': keyboardPwdName,
                'newKeyboardPwd': newKeyboardPwd.toString(),
                'startDate': startDate.toString(),
                'endDate': endDate.toString(),
                'changeType': '2',
                'date': date.toString(),
              },
            )
            .timeout(const Duration(seconds: 30));
        print('CHANGE PASSCODE STATUS: ${response.statusCode}');
        print('CHANGE PASSCODE BODY: ${response.body}');
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
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
