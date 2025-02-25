// lib/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/storage_service.dart';
import '../config/app_config.dart';

class AuthService {
  static final AppConfig _config = AppConfig();

  // 로그인
  static Future<bool> login(String name, String password) async {
    final url = Uri.parse('${_config.apiUrl}/auth/login');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'password': password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        await secureStorage.write(key: 'jwt_token', value: data['access_token']);
        await secureStorage.write(key: 'user_id', value: data['user_id'].toString());
        await secureStorage.write(key: 'user_name', value: data['user_name']);
        return true;
      } else {
        print('로그인 실패: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('로그인 요청 중 오류 발생: $e');
      return false;
    }
  }

  // 회원가입
  static Future<bool> register(String name, String password) async {
    final url = Uri.parse('${_config.apiUrl}/auth/signup');
    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'name': name, 'password': password}),
      );
      if (response.statusCode == 200) {
        return true;
      } else {
        print('회원가입 실패: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('회원가입 요청 중 오류 발생: $e');
      return false;
    }
  }

  // 내 정보 조회
  static Future<Map<String, dynamic>?> fetchUserInfo() async {
    final token = await getToken();
    if (token == null) return null;

    final url = Uri.parse('${_config.apiUrl}/user/get');
    try {
      final response = await http.get(
        url,
        headers: await _config.getAuthHeaders(),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        print('사용자 정보 불러오기 실패: ${response.statusCode} ${response.body}');
        return null;
      }
    } catch (e) {
      print('사용자 정보 요청 중 오류 발생: $e');
      return null;
    }
  }

  // secureStorage에서 토큰을 가져오는 정적 메서드
  static Future<String?> getToken() async {
    return await secureStorage.read(key: 'jwt_token');
  }

  // secureStorage에서 사용자 ID를 가져오는 정적 메서드
  static Future<String?> getUserId() async {
    return await secureStorage.read(key: 'user_id');
  }

  // secureStorage에서 사용자 이름을 가져오는 정적 메서드
  static Future<String?> getUserName() async {
    return await secureStorage.read(key: 'user_name');
  }

  // 로그인 상태 확인
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // 로그아웃
  static Future<void> logout() async {
    await secureStorage.delete(key: 'jwt_token');
    await secureStorage.delete(key: 'user_id');
    await secureStorage.delete(key: 'user_name');
  }
}