import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import 'package:get/get.dart';

import '../../../../../core/i_local_preferences.dart';
import '../../domain/entities/user.dart';
import 'i_auth_source.dart';

class AuthRobleSource implements IAuthenticationSource {
  final http.Client httpClient;
  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/auth/database_364931dc19';

  String? _accessToken;
  String? _refreshToken;
  final ILocalPreferences _sharedPreferences = Get.find<ILocalPreferences>();

  AuthRobleSource({http.Client? client}) : httpClient = client ?? http.Client();

  @override
  Future<User?> login(String email, String password) async {
    final response = await httpClient.post(
      Uri.parse("$baseUrl/login"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      final userData = data['user'];

      _accessToken = data['accessToken'];
      _refreshToken = data['refreshToken'];
      await _sharedPreferences.storeData('token', _accessToken);
      await _sharedPreferences.storeData('refreshToken', _refreshToken);

      return User.fromJson(userData);
    } else {
      final body = jsonDecode(response.body);
      logError("Login error ${response.statusCode}: ${body['message']}");
      print('❌ Login fallido: ${body['message']}');
      return null;
    }
  }

  @override
  Future<bool> signUp(User user) async {
    final response = await httpClient.post(
      Uri.parse("$baseUrl/signup-direct"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({
        "email": user.email,
        "password": user.password,
        "name": user.name,
      }),
    );
    if (response.statusCode == 201 || response.statusCode == 200) {
      return true;
    }
    return false;
  }

  @override
  Future<bool> logOut() async {
     _accessToken = await _sharedPreferences.retrieveData<String>('token');

    if (_accessToken == null) {
      return true;
    }

    final response = await httpClient.post(
      Uri.parse("$baseUrl/logout"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_accessToken',
      },
    );

    _accessToken = null;
    _refreshToken = null;
    await _sharedPreferences.removeData('token');
    await _sharedPreferences.removeData('refreshToken');
    await _sharedPreferences.removeData('email');
    await _sharedPreferences.removeData('password');
    await _sharedPreferences.storeData('remember_me', false);

    return response.statusCode == 200;
  }

  @override
  Future<bool> forgotPassword(String email) async {
    final response = await httpClient.post(
      Uri.parse("$baseUrl/forgot-password"),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, String>{"email": email}),
    );

    logInfo(response.statusCode);
    if (response.statusCode == 201) {
      return Future.value(true);
    } else {
      final Map<String, dynamic> errorBody = json.decode(response.body);
      final String errorMessage = errorBody['message'];
      logError(
        "forgotPassword endpoint got error code ${response.statusCode} $errorMessage for email: $email",
      );
      return Future.error('Error code ${response.statusCode}');
    }
  }

  @override
  Future<bool> resetPassword(
    String email,
    String newPassword,
    String validationCode,
  ) async {
    return Future.value(true);
  }

  // ✅ Método mejorado para refrescar token
  Future<bool> refreshToken() async {
    // Cargar refresh token desde storage si no está en memoria
    _refreshToken ??= await _sharedPreferences.retrieveData<String>(
      'refreshToken',
    );

    if (_refreshToken == null) return false;

    final response = await httpClient.post(
      Uri.parse("$baseUrl/refresh"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({"refreshToken": _refreshToken}),
    );

    logInfo("Refresh token status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      _accessToken = data['accessToken'];
      _refreshToken = data['refreshToken'];

      // ✅ Guardar nuevos tokens
      await _sharedPreferences.storeData('token', _accessToken);
      await _sharedPreferences.storeData('refreshToken', _refreshToken);

      return true;
    }
    return false;
  }

  // ✅ Método mejorado para validar token
  Future<bool> validateToken() async {
    // Cargar token desde storage si no está en memoria
    _accessToken ??= await _sharedPreferences.retrieveData<String>('token');
    

    if (_accessToken == null) return false;

    try {
      final response = await httpClient.get(
        Uri.parse("$baseUrl/validate"),
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        // Token expirado, intentar refrescar
        logInfo("Token expired, attempting refresh...");
        final refreshed = await refreshToken();
        if (refreshed) {
          // Validar nuevamente con el token refrescado
          return await validateToken();
        }
      }

      return false;
    } catch (e) {
      logError("Error validating token: $e");
      return false;
    }
  }

  Future<bool> verifyToken(String token) async {
    final response = await httpClient.post(
      Uri.parse("$baseUrl/verify"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({"token": token}),
    );

    return response.statusCode == 200;
  }

  // ✅ Método para obtener el usuario actual (opcional)
  Future<User?> getCurrentUser() async {
    _accessToken ??= await _sharedPreferences.retrieveData<String>('token');

    if (_accessToken == null) return null;

    try {
      final response = await httpClient.get(
        Uri.parse("$baseUrl/me"), // Asumiendo que existe este endpoint
        headers: {'Authorization': 'Bearer $_accessToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return User.fromJson(data);
      }
    } catch (e) {
      logError("Error getting current user: $e");
    }

    return null;
  }

  // ✅ Método para inicializar tokens desde storage
  Future<void> initializeFromStorage() async {
    _accessToken = await _sharedPreferences.retrieveData<String>('token');
    _refreshToken = await _sharedPreferences.retrieveData<String>(
      'refreshToken',
    );
  }
}
