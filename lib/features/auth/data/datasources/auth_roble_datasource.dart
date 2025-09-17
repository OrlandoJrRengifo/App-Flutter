import 'dart:convert';
import 'dart:developer';
import 'package:http/http.dart' as http;
import 'package:loggy/loggy.dart';
import 'package:get/get.dart';

import '../../../../../core/i_local_preferences.dart';
import '../../domain/entities/user.dart';
//import '../../../courses/data/datasources/course_roble_datasource.dart';
import 'i_auth_source.dart';

class AuthRobleSource implements IAuthenticationSource {
  final http.Client httpClient;
  final String baseUrl =
      'https://roble-api.openlab.uninorte.edu.co/auth/database_364931dc19';

  String? _accessToken;
  String? _refreshToken;

  AuthRobleSource({http.Client? client}) : httpClient = client ?? http.Client();

  @override
  Future<User?> getUser(String userId) async {
    //no sabia que estaba asi que esta por defecto
    final response = await httpClient.get(
      Uri.parse("$baseUrl/users/$userId"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_accessToken',
      },
    );

    logInfo("Get user status: ${response.statusCode}");
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      final body = jsonDecode(response.body);
      logError("Get user error ${response.statusCode}: ${body['message']}");
      return null;
    }
  }

  @override
  Future<User?> login(String email, String password) async {
    final response = await httpClient.post(
      Uri.parse("$baseUrl/login"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      _accessToken = data['accessToken'];
      _refreshToken = data['refreshToken'];
      final ILocalPreferences sharedPreferences = Get.find();
      sharedPreferences.storeData('token', _accessToken);
      sharedPreferences.storeData('refreshToken', _refreshToken);
      logInfo("Token: $_accessToken"
          "\nRefresh Token: $refreshToken");
      return User.fromJson(data['user']);
    } else {
      final body = jsonDecode(response.body);
      logError("Login error ${response.statusCode}: ${body['message']}");
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
    if (_accessToken == null) return true;
    final response = await httpClient.post(
      Uri.parse("$baseUrl/logout"),
      headers: {
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $_accessToken',
      },
    );

    logInfo("Logout status: ${response.statusCode}");
    _accessToken = null;
    _refreshToken = null;

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

  Future<bool> refreshToken() async {
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
      return true;
    }
    return false;
  }

  Future<bool> validateToken() async {
    if (_accessToken == null) return false;

    final response = await httpClient.get(
      Uri.parse("$baseUrl/validate"),
      headers: {'Authorization': 'Bearer $_accessToken'},
    );

    return response.statusCode == 200;
  }

  Future<bool> verifyToken(String token) async {
    final response = await httpClient.post(
      Uri.parse("$baseUrl/verify"),
      headers: {'Content-Type': 'application/json; charset=UTF-8'},
      body: jsonEncode({"token": token}),
    );

    return response.statusCode == 200;
  }
}
