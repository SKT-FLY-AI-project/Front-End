// lib/config/app_config.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';

class AppConfig {
  // 싱글톤 패턴 구현
  static final AppConfig _instance = AppConfig._internal();

  factory AppConfig() {
    return _instance;
  }

  AppConfig._internal();

  // API 설정
  String baseUrl = "https://17bc-116-42-177-239.ngrok-free.app/";
  String apiUrl = "https://17bc-116-42-177-239.ngrok-free.app/api";
  String wsUrl = "ws://17bc-116-42-177-239.ngrok-free.app/ws";

  // 사용자 정보
  String defaultUserId = "temp";

  // API 호출 관련 메서드
  Future<Map<String, String>> getAuthHeaders() async {
    final token = await secureStorage.read(key: 'jwt_token');
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
}