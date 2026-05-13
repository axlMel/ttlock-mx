import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:crypto/crypto.dart';

class AuthService {  
  final String baseUrl = 'https://euapi.ttlock.com';

  Future<String?> login(String username, String password) async{
    print("INICIADNO REQUEST");
    
    final url = Uri.parse('$baseUrl/oauth2/token');
    final bytes = utf8.encode(password);
    final md5Password = md5.convert(bytes).toString();

    for (int i=0;i < 3; i++){
      try {
        print("USERNAME: $username");
        print("MD5 PASS: $md5Password");
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
        ).timeout(const Duration(seconds: 45));
        print("STATUS: ${response.statusCode}");
        print("BODY: ${response.body}");
        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          return data['access_token'];
        }
      } catch (e) {
        print('Intento ${i + 1} falló: $e');
      }
      await Future.delayed(const Duration(seconds: 2));
    }
    return null;
  }
}