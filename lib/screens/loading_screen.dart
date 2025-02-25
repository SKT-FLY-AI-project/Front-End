import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:camera/camera.dart';
import 'home_screen.dart';

class SplashScreen extends StatefulWidget {
  final CameraDescription camera;

  const SplashScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );

    _progressAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();

    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        // Navigator.pushReplacement(
        //   context,
        //   PageRouteBuilder(
        //     pageBuilder: (_, __, ___) => HomeScreen(token),
        //     transitionsBuilder: (_, animation, __, child) {
        //       return FadeTransition(opacity: animation, child: child);
        //     },
        //     transitionDuration: const Duration(milliseconds: 800),
        //   ),
        // );
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),  // 배경색 연한 회색
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 상단 여백
          const Spacer(),

          // "작품 감상의 새로운 경험" 텍스트
          const Text(
            '작품 감상의\n새로운 경험',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // 로고 이미지
          SvgPicture.asset(
            'assets/icon_artchat.svg',
            width: 120,
            height: 120,
          ),
          const SizedBox(height: 8),

          // "ArtChemy" 텍스트
          const Text(
            'ArtChemy',
            style: TextStyle(
              color: Color(0xFF1E40AF),  // 진한 파란색
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),

          // 하단 여백
          const Spacer(),

          // 진행 바
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50),
            child: AnimatedBuilder(
              animation: _progressAnimation,
              builder: (context, child) {
                return ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: _progressAnimation.value,
                    backgroundColor: Colors.black12,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1E40AF)), // 파란색
                    minHeight: 4,
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }
}
