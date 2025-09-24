import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/auth_controller.dart';
import 'login_page.dart';
import '../../../courses/ui/pages/courses_page.dart'; 
import '../../../../../core/i_local_preferences.dart';

// Screen que verifica credenciales guardadas y hace auto-login
class SessionCheckScreen extends StatefulWidget {
  const SessionCheckScreen({super.key});

  @override
  State<SessionCheckScreen> createState() => _SessionCheckScreenState();
}

class _SessionCheckScreenState extends State<SessionCheckScreen> {
  @override
  void initState() {
    super.initState();
    _checkCredentialsAndNavigate();
  }

  Future<void> _checkCredentialsAndNavigate() async {
    await Future.delayed(const Duration(seconds: 2));

    final authController = Get.find<AuthenticationController>();
    final prefs = Get.find<ILocalPreferences>();

    final rememberMe = await prefs.retrieveData<bool?>('remember_me') ?? false;
    if (rememberMe) {
      final email = await prefs.retrieveData<String>('email');
      final password = await prefs.retrieveData<String>('password');

      if (email != null && password != null) {
        final success = await authController.login(email.trim(), password);
        if (success) {
          Get.off(() => const CourseDashboard());
          return;
        }
      }
    }

    // si no había rememberMe o falló el login, ir al login manual
    Get.off(() => const LoginPage());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue, Colors.blue.withOpacity(0.8)],
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Icon(Icons.school_rounded, size: 100, color: Colors.white),
              SizedBox(height: 24),

              // Título
              Text(
                'Sistema de Cursos',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 40),

              // Indicador de carga
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
              SizedBox(height: 16),

              // Texto de estado
              Text(
                'Iniciando...',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
