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
  String domain = "gazelle-magnetic-amazingly.ngrok-free.app";
  String baseUrl = "https://gazelle-magnetic-amazingly.ngrok-free.app/";
  String apiUrl = "https://gazelle-magnetic-amazingly.ngrok-free.app/api";
  String wsUrl = "wss://gazelle-magnetic-amazingly.ngrok-free.app/ws"; // wsUrl도 보안을 위해 wss://로 사용

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