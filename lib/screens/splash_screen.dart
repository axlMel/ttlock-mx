import 'package:flutter/material.dart';
import '../services/auth_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() =>
      _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    checkLogin();
  }

  Future<void> checkLogin() async {
    final token =
        await AuthManager.getToken();

    // Espera pequeña para ver splash
    await Future.delayed(
      const Duration(seconds: 1),
    );
    if (!mounted) return;
    if (token != null) {
      print('✅ SESIÓN ACTIVA');
      Navigator.pushReplacementNamed(
        context,
        '/home',
      );
    } else {
      print('❌ SIN SESIÓN');
      Navigator.pushReplacementNamed(
        context,
        '/login',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}