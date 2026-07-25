import 'package:api_app/models/qrcodes/qrcode.dart';
import 'package:api_app/models/qrcodes/qrcode_creation_result.dart';
import 'package:api_app/models/qrcodes/cyclic_config.dart';
import 'package:http/http.dart' as http;
import 'dart:async';
import "dart:convert";

class WifiQrcodeService {
  static const String clientId = '096a5c62f3ae47c39e206d410119d7b3';
  static const String baseUrl = 'https://euapi.ttlock.com';

  Future<List<Qrcode>> getAllQrcodes(String token, int lockId) async {
    final date = DateTime.now().millisecondsSinceEpoch;
    final url = Uri.parse(
      '$baseUrl/v3/qrCode/list'
      '?clientId=$clientId'
      '&accessToken=$token'
      '&lockId=$lockId'
      '&pageNo=1'
      '&pageSize=100'
      '&date=$date'
    );
    print('OBTENIENDO CODIGOS QR');
    print('LOCK ID: $lockId');
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
        final List<dynamic> accessCodesJson = data['list'] ?? [];
        return accessCodesJson.map((json) => Qrcode.fromJson(json)).toList();
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

  Future<QrcodeCreationResult> getQrcode(
    String token,
    int lockId,
    String? name,
    int type,
    int? startDate,
    int? endDate,
    int? refreshTime,
    List<CyclicConfig>? cyclicConfig,
  ) async {
    final url = Uri.parse('$baseUrl/v3/qrCode/add');
    final date = DateTime.now().millisecondsSinceEpoch;
    print('OBTENIENDO QR ALEATORIO');
    print('LOCK ID: $lockId');
    for (var i = 0; i < 3; i++) {
      try {
        final response = await http.post(
          url,
          body: {
            'clientId': clientId,
            'accessToken': token,
            'lockId': lockId.toString(),
            'name': name,
            'type': type.toString(),
            'startDate': startDate.toString(),
            'endDate': endDate.toString(),
            'refreshTime': refreshTime.toString(),
            'cyclicConfig': cyclicConfig == null
            ? ''
            : jsonEncode(
                cyclicConfig.map((e) => e.toJson()).toList(),
              ),
            'addType': 0.toString(),
            'date': date.toString(),
          },
        ).timeout(const Duration(seconds: 30));
        print('GETQR STATUS: ${response.statusCode}');
        print('BODY: ${response.body}');
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }
        final data = jsonDecode(response.body);
        if (data.containsKey('errcode') && data['errcode'] != 0) {
          throw Exception('${data['errmsg']} (${data['errcode']})');
        }
        final result = QrcodeCreationResult.fromJson(data);
        return result;
      } on TimeoutException {
        print('Timeout intento ${i + 1}');
      } on http.ClientException {
        print('Error de conexión intento ${i + 1}');
      } catch (e) {
        rethrow;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    throw Exception('No fue posible conectar con el servidor');
  }

  Future<void> deleteQrcode(
    String token,
    int lockId,
    int qrCodeId,
    int deleteType,
  ) async {
    final url = Uri.parse('$baseUrl/v3/qrCode/delete');
    final date = DateTime.now().millisecondsSinceEpoch;
    print('BORRANDO CODIGO');
    print('LOCK ID: $lockId');
    for (var i = 0; i < 3; i++) {
      try {
        final response = await http.post(
          url,
          body: {
            'clientId': clientId,
            'accessToken': token,
            'lockId': lockId.toString(),
            'qrCodeId': qrCodeId.toString(),
            'deleteType': deleteType.toString(),
            'date': date.toString(),
          },
        )
        .timeout(const Duration(seconds: 30));
        print('DELETE QRCODE STATUS: ${response.statusCode}');
        print('DELETE QRCODE BODY: ${response.body}');
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }
        final data = jsonDecode(response.body);
        if (data['errcode']!=0) {
          throw Exception('${data['errmsg']} (${data['errcode']})');
        }
        return;
      }
      on TimeoutException {
        print('Timeout intento ${i+1}');
      } 
      on http.ClientException{
        print('Error de conexión intento ${i+1}');
      }
      catch(e){
        rethrow;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    throw Exception('No fue posible conectar con el servidor');
  }

  Future<void> updateQrcode(
    String token,
    int qrCodeId,
    String? name,
    int? startDate,
    int? endDate,
    int? refreshTime,
    int type,
    List<CyclicConfig>? cyclicConfig,
    int changeType,
  ) async {
    final url = Uri.parse('$baseUrl/v3/qrCode/update');
    final date = DateTime.now().millisecondsSinceEpoch;
    print('ACTUALIZANDO QR');
    print('LOCK ID: $qrCodeId');
    for (var i = 0; i < 3; i++) {
      try {
        final response = await http
        .post(
          url,
          body: {
            'clientId': clientId,
            'accessToken': token,
            'qrCodeId': qrCodeId.toString(),
            'name': name,
            'startDate': startDate.toString(),
            'endDate': endDate.toString(),
            'refreshTime': refreshTime.toString(),
            'cyclicConfig': cyclicConfig == null
            ? ''
            : jsonEncode(
                cyclicConfig.map((e) => e.toJson()).toList(),
              ),
            'date': date.toString(),
            'type': type.toString(),
            'changeType': 0.toString(),
          },
        )
        .timeout(const Duration(seconds: 30));
        print('CHANGE ALLQRCODE STATUS: ${response.statusCode}');
        print('CHANGE ALLQRCODE BODY: ${response.body}');
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }
        final data = jsonDecode(response.body);
        if (data['errcode']!=0) {
          throw Exception('${data['errmsg']} (${data['errcode']})');
        }
        return;
      }
      on TimeoutException {
        print('Timeout intento ${i+1}');
      } 
      on http.ClientException{
        print('Error de conexión intento ${i+1}');
      }
      catch(e){
        rethrow;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    throw Exception('No fue posible conectar con el servidor');
  }

  Future<void> deleteAllQrcodes(
    String token,
    int lockId,
  ) async {
    final url = Uri.parse('$baseUrl/v3/qrCode/clear');
    final date = DateTime.now().millisecondsSinceEpoch;
    print('BORRANDO CODIGO');
    print('LOCK ID: $lockId');
    for (var i = 0; i < 3; i++) {
      try {
        final response = await http.post(
          url,
          body: {
            'clientId': clientId,
            'accessToken': token,
            'lockId': lockId.toString(),
            'type': 0.toString(),
            'date': date.toString(),
          },
        )
        .timeout(const Duration(seconds: 30));
        print('DELETE ALLQRCODE STATUS: ${response.statusCode}');
        print('DELETE ALLQRCODE BODY: ${response.body}');
        if (response.statusCode != 200) {
          throw Exception('HTTP ${response.statusCode}');
        }
        final data = jsonDecode(response.body);
        if (data['errcode']!=0) {
          throw Exception('${data['errmsg']} (${data['errcode']})');
        }
        return;
      }
      on TimeoutException {
        print('Timeout intento ${i+1}');
      } 
      on http.ClientException{
        print('Error de conexión intento ${i+1}');
      }
      catch(e){
        rethrow;
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    throw Exception('No fue posible conectar con el servidor');
  }
}
