import 'dart:convert';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import '../../domain/entities/assessment.dart';
import 'i_assessment_source.dart';
import '../../../../core/i_local_preferences.dart';

class AssessmentRobleDataSource implements IAssessmentDataSource {
  final http.Client httpClient;
  final String baseUrl = "https://roble-api.openlab.uninorte.edu.co/database/database_364931dc19";

  AssessmentRobleDataSource({http.Client? client}) : httpClient = client ?? http.Client();

  Future<String?> _getToken() async {
    final ILocalPreferences prefs = Get.find();
    return prefs.retrieveData<String>('token');
  }

  @override
  Future<List<Assessment>> getAssessmentsByActivity(String activityId) async {
    final token = await _getToken();
    if (token == null) return [];

    final uri = Uri.parse("$baseUrl/read").replace(queryParameters: {
      "tableName": "assessments",
      "activity_id": activityId,
    });

    final res = await httpClient.get(uri, headers: {"Authorization": "Bearer $token"});
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => Assessment.fromMap(e)).toList();
    }
    return [];
  }

  @override
  Future<List<Assessment>> getAssessmentsByActivityAndRater(String activityId, String rater) async {
    final token = await _getToken();
    if (token == null) return [];

    final uri = Uri.parse("$baseUrl/read").replace(queryParameters: {
      "tableName": "assessments",
      "activity_id": activityId,
      "rater": rater,
    });

    final res = await httpClient.get(uri, headers: {"Authorization": "Bearer $token"});
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => Assessment.fromMap(e)).toList();
    }
    return [];
  }

  @override
  Future<List<Assessment>> getAssessmentsByActivityAndToRate(String activityId, String toRate) async {
    final token = await _getToken();
    if (token == null) return [];

    final uri = Uri.parse("$baseUrl/read").replace(queryParameters: {
      "tableName": "assessments",
      "activity_id": activityId,
      "to_rate": toRate,
    });

    final res = await httpClient.get(uri, headers: {"Authorization": "Bearer $token"});
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body) as List;
      return list.map((e) => Assessment.fromMap(e)).toList();
    }
    return [];
  }

  @override
  Future<bool> createAssessment(Assessment assessment) async {
    final token = await _getToken();
    if (token == null) return false;

    final body = {
      "tableName": "assessments",
      "records": [assessment.toMap()],
    };

    final res = await httpClient.post(
      Uri.parse("$baseUrl/insert"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json; charset=UTF-8"
      },
      body: jsonEncode(body),
    );

    return res.statusCode == 200 || res.statusCode == 201;
  }

  @override
  Future<bool> gradeAssessment(String assessmentId, int punctuality, int contributions, int commitment, int attitude) async {
    final token = await _getToken();
    if (token == null) return false;

    final body = {
      "tableName": "assessments",
      "idColumn": "_id",
      "idValue": assessmentId,
      "updates": {
        "punctuality": punctuality,
        "contributions": contributions,
        "commitment": commitment,
        "attitude": attitude,
      },
    };

    final res = await httpClient.put(
      Uri.parse("$baseUrl/update"),
      headers: {
        "Authorization": "Bearer $token",
        "Content-Type": "application/json; charset=UTF-8"
      },
      body: jsonEncode(body),
    );

    return res.statusCode == 200;
  }
}
