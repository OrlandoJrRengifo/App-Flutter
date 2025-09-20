import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import 'registerScreen.dart';
import '../../../courses/ui/pages/courses_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passController = TextEditingController();
  String? _error;

  final authController = Get.find<AuthenticationController>();

  Future<void> _login() async {
    final success = await authController.login(
      _emailController.text,
      _passController.text,
    );

    setState(() {
      _error = success ? null : 'Usuario o contraseña incorrectos';
    });

    if (success) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('¡Inicio de sesión exitoso!')),
    );
    Get.off(() => const CourseDashboard());
  }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Ingresar'),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              child: const Text('Registrarse'),
            ),
          ],
        ),
      ),
    );
  }
}
