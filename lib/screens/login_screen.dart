import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'home_screen.dart';
import 'signup_screen.dart';
import '../services/auth_service.dart'; // auth_service.dart 파일 import

// LoginScreen을 StatefulWidget으로 전환하여 텍스트 입력값을 관리합니다.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // 아이디(또는 이름)와 비밀번호를 위한 TextEditingController 생성
  final TextEditingController _idController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _idController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 로그인 버튼을 눌렀을 때 호출되는 함수
  void _handleLogin() async {
    final name = _idController.text;
    final password = _passwordController.text;

    // 입력 검증
    if (name.isEmpty || password.isEmpty) {
      _showErrorDialog('오류', '아이디와 비밀번호를 모두 입력해주세요.');
      return;
    }

    final success = await AuthService.login(name, password);

    if (success) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => HomeScreen(),
        ),
      );
    } else {
      _showErrorDialog('로그인 실패', '아이디 또는 비밀번호가 올바르지 않습니다.\n다시 시도해주세요.');
    }
  }

  // 회원가입 버튼을 눌렀을 때 호출되는 함수
  void _handleRegister() async {
    Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const SignupScreen())
    );
  }

  // 에러 다이얼로그 표시 함수
  Future<void> _showErrorDialog(String title, String message) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E40AF).withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.error_outline_rounded,
                    color: Color(0xFF1E40AF),
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                // 제목
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                // 내용
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 28),
                // 확인 버튼
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: Container(
                    width: double.infinity,
                    height: 50,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E40AF),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: SingleChildScrollView( // 화면이 작을 때 스크롤 가능하도록 함
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'ArtChemy',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '작품 감상의 새로운 경험',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 40),
                  buildInputField('아이디', controller: _idController),
                  const SizedBox(height: 20),
                  buildInputField('비밀번호', isPassword: true, controller: _passwordController),
                  const SizedBox(height: 30),
                  buildButton(
                    '로그인',
                    const Color(0xFF1E40AF),
                    Colors.white,
                    onTap: _handleLogin,
                  ),
                  const SizedBox(height: 10),
                  buildButton(
                    '회원가입',
                    Colors.white,
                    const Color(0xFF1E40AF),
                    border: true,
                    onTap: _handleRegister,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'or',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  buildKakaoButton(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // TextField에 텍스트 입력값을 제어하기 위해 controller를 받도록 수정
  Widget buildInputField(String label, {bool isPassword = false, TextEditingController? controller}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
          ),
        ),
        const SizedBox(height: 5),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: const Color(0xFF1E40AF), width: 2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: TextField(
              controller: controller,
              style: const TextStyle(
                color: Colors.black,
              ),
              obscureText: isPassword,
              decoration: const InputDecoration(
                border: InputBorder.none,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget buildButton(String text, Color bgColor, Color textColor, {bool border = false, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: border ? Colors.white : bgColor,
          border: border ? Border.all(color: bgColor, width: 2) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildKakaoButton() {
    return GestureDetector(
      onTap: () {
        // 카카오 로그인 로직 구현
        print('카카오 로그인 클릭');
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          color: const Color(0xFFFEE500),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SvgPicture.asset(
              'assets/kakao_icon.svg',
              height: 20,
              width: 20,
              fit: BoxFit.contain,
            ),
            const SizedBox(width: 8),
            const Text(
              '카카오 로그인',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}