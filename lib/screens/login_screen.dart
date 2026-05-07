import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState(); 
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();
  bool isLoading = false;

  void login() async {
    print("🔥 CLICK LOGIN");

    setState(() {
      isLoading = true;
    });

    try {
      final token = await authService.login(
        usernameController.text,
        passwordController.text,
      );

      print("✅ TOKEN: $token");

      setState(() {
        isLoading = false;
      });

      if (token != null) {
        Navigator.pushReplacementNamed(
          context,
          '/home',
          arguments: token,
        );
      } else {
        print("❌ LOGIN FALLÓ");
      }
    } catch (e) {
      print("💥 ERROR: $e");

      setState(() {
        isLoading = false;
      });
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login GTLock'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Usuario',
              ),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
              ),
            ),
            const SizedBox(height:20),
            isLoading ? const CircularProgressIndicator() : ElevatedButton(onPressed: login, child: const Text('Login'),),
          ],
        ),
      ),
    );
  }
}