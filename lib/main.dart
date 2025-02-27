import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'services/permission_service.dart';
import 'services/auth_service.dart';
import 'screens/loading_screen.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ArtChemy',
      home: FutureBuilder<String?>(
        future: AuthService.getToken(), // 로그인 토큰을 비동기적으로 가져옴
        builder: (context, snapshot) {
          // 로딩 중에는 간단한 로딩 위젯을 표시
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }
          // 토큰이 존재하면 홈 화면으로, 없으면 로그인 화면으로 이동
          if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
            return const HomeScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}