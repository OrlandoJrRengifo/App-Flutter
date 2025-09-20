import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _emailController = TextEditingController();
  final _nameController = TextEditingController();
  final _passController = TextEditingController();
  String? _error;
  String? _success;

  // Obtienes el controlador desde GetX
  final authController = Get.find<AuthenticationController>();

  Future<void> _register() async {
    final success = await authController.signUp(
      _emailController.text,
      _nameController.text,
      _passController.text,
    );

    setState(() {
      if (success) {
        _success = '¡Registro exitoso!';
        _error = null;
      } else {
        _error = 'El usuario ya existe';
        _success = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Nombre'),
            ), 
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Contraseña'),
              obscureText: true,
            ),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Colors.red)),
            if (_success != null)
              Text(_success!, style: const TextStyle(color: Colors.green)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _register,
              child: const Text('Registrar'),
            ),
          ],
        ),
      ),
    );
  }
}
