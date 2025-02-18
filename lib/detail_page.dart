import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // flutter_svg 사용을 위한 import

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false, // 디버그 배너 제거
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const FigmaScreen(),
    );
  }
}

class FigmaScreen extends StatelessWidget {
  const FigmaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SizedBox(
          width: 412,
          height: 892,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // 세로 중앙 정렬
            children: [
              // "Art Teller" 텍스트
              const Text(
                'Art Teller',
                style: TextStyle(
                  color: Color(0xFFD55E00),
                  fontSize: 40,
                  fontFamily: 'KoddiUD OnGothic',
                  fontWeight: FontWeight.w700,
                  height: 1.20,
                ),
              ),
              const SizedBox(height: 30), // 간격 조정

              // "나의 미술관" 텍스트
              const Text(
                '나의 미술관',
                style: TextStyle(
                  color: Color(0xFFD55E00),
                  fontSize: 40,
                  fontFamily: 'KoddiUD OnGothic',
                  fontWeight: FontWeight.w700,
                  height: 1.20,
                ),
              ),
              const SizedBox(height: 30), // 간격 조정

              // 날짜 박스
              Container(
                width: 218,
                height: 39,
                decoration: BoxDecoration(
                  color: Color(0xFFD55E00),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Color(0xFFD55E00), width: 1),
                ),
                child: const Center(
                  child: Text(
                    '2025. 02. 12',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'KoddiUD OnGothic',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50), // 간격 조정

              // 중앙 세로 정렬된 SVG 이미지들
              Column(
                children: [
                  SvgPicture.asset(
                    'assets/icon_pictop.svg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                  const SizedBox(height: 40), // 간격
                  SvgPicture.asset(
                    'assets/icon_picbot.svg',
                    width: 200,
                    height: 200,
                    fit: BoxFit.contain,
                    alignment: Alignment.center,
                  ),
                ],
              ),
              const SizedBox(height: 50), // 간격 조정

              // "더보기" 버튼
              Container(
                width: 100,
                height: 39,
                decoration: ShapeDecoration(
                  color: Color(0xFFD55E00),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(width: 1, color: Color(0xFFD55E00)),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Center(
                  child: Text(
                    '더보기',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontFamily: 'KoddiUD OnGothic',
                      fontWeight: FontWeight.w700,
                      height: 0.83,
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
