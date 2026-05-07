import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {  
  final String baseUrl = 'https://usapi.ttlock.com';

  Future<String?> login(String username, String password) async{
    print("📡 INICIANDO REQUEST");
    
    final url = Uri.parse('https://euapi.ttlock.com/oauth2/token');
    final bytes = utf8.encode(password);
    final md5Password = md5.convert(bytes).toString();
    try {
      print("👤 USERNAME: $username");
      print("🔑 MD5 PASS: $md5Password");
      final response = await http.post(
        url,
        headers: {
          'Content-Type' : 'application/x-www-form-urlencoded',
          'Accept' : 'application/json',
        },
        body:{
          'clientId' : '096a5c62f3ae47c39e206d410119d7b3',
          'clientSecret' : '554a13ae72d26ab6973726b34b6f33f0',
          'username' : username,
          'password' : md5Password,
          'grant_type': 'password',
        },
      ).timeout(const Duration(seconds: 10));
      print("📊 STATUS: ${response.statusCode}");
      print("📦 BODY: ${response.body}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['access_token'];
      } else {
        print(response.body);
        return null;
      }
    } catch (e) {
      print("💥 ERROR EN REQUEST: $e");
      return null;
    }
    
  }
}