import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/auth_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  final AuthService authService = AuthService();
  bool isLoading = false;

  late AnimationController controller;
  late Animation<double> animation;

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
        await AuthManager.saveToken(token);
        Navigator.pushReplacementNamed(context, '/home', arguments: token);
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
  void initState() {
    // TODO: implement initState
    super.initState();
    controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    animation = CurvedAnimation(parent: controller, curve: Curves.easeOutBack);
    controller.reset();
    controller.forward();
  }

  @override
  void dispose() {
    // TODO: implement dispose
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 248, 250),
      //appBar: AppBar(title: const Text('Login GTLock')),
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Positioned(
                top: -250 + (190 * animation.value),
                right: -40,
                child: child!,
              );
            },
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 202, 200, 207),
                shape: BoxShape.circle,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Positioned(
                top: -300 + (220 * animation.value),
                right: -60,
                child: child!,
              );
            },
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 37, 23, 100),
                shape: BoxShape.circle,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Positioned(
                bottom: 500 + (-625 * animation.value),
                left: 10,
                child: child!,
              );
            },
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 202, 200, 207),
                shape: BoxShape.circle,
              ),
            ),
          ),
          AnimatedBuilder(
            animation: animation,
            builder: (context, child) {
              return Positioned(
                bottom: 500 + (-640 * animation.value),
                left: 0,
                child: child!,
              );
            },
            child: Container(
              height: 200,
              width: 200,
              decoration: BoxDecoration(
                color: Color.fromARGB(255, 37, 23, 100),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 20,
                        offset: Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "SIGN IN",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 30),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          controller: usernameController,
                          decoration: InputDecoration(
                            labelText: 'Usuario',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(
                              Icons.person_outline,
                              color: Colors.grey,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 25),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: Offset(0, 3),
                            ),
                          ],
                        ),
                        child: TextField(
                          obscureText: true,
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: 'Contraseña',
                            filled: true,
                            fillColor: Colors.white,
                            prefixIcon: const Icon(
                              Icons.lock_outline,
                              color: Colors.grey,
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade300,
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Colors.grey.shade400,
                                width: 1.2,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 40),
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: isLoading
                            ? const Center(
                                child: SizedBox(
                                  width: 28,
                                  height: 30,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 3,
                                    color: Color.fromARGB(255, 37, 23, 100),
                                  ),
                                ),
                              )
                            : ElevatedButton(
                                onPressed: login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Color.fromARGB(
                                    255,
                                    37,
                                    23,
                                    100,
                                  ),
                                  elevation: 4,
                                  shadowColor: Colors.indigo,
                                ),
                                child: const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: Text(
                          "Olvidaste tu contraseña?",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blueGrey,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      /* body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(labelText: 'Usuario'),
            ),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Contraseña'),
            ),
            const SizedBox(height: 20),
            isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(onPressed: login, child: const Text('Login')),
          ],
        ),
      ),*/
    );
  }
}
