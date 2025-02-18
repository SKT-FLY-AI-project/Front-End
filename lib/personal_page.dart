import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  // flutter_svg를 사용하기 위한 import

void main() {
  runApp(FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color.fromARGB(255, 18, 32, 47),
      ),
      home: Scaffold(
        body: ListView(
          children: [
            FigmaScreen(),
          ],
        ),
      ),
    );
  }
}

class FigmaScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 412,
          height: 892,
          child: Stack(
            children: [
              Positioned(
                left: 119,
                top: 120,
                child: Text(
                  'Art Teller',
                  style: TextStyle(
                    color: const Color(0xFFD55E00),
                    fontSize: 40,
                    fontFamily: 'KoddiUD OnGothic',
                    fontWeight: FontWeight.w700,
                    height: 0.50,
                    letterSpacing: 0.25,
                  ),
                ),
              ),
              // Image container
              Positioned(
                left: 115,
                top: 170,
                child: Container(
                  width: 178,
                  height: 207,
                  decoration: BoxDecoration(
                    color: const Color(0xFF211B1B),
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
              // Text below image
              Positioned(
                left: 155,
                top: 340,
                child: SizedBox(
                  width: 140,
                  child: Text(
                    '패기3팀',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,  // 폰트 크기를 크게 수정
                      fontFamily: 'KoddiUD OnGothic',
                      fontWeight: FontWeight.w700,
                      height: 1.0,  // 텍스트의 줄 간격을 1로 설정
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
              ),
              Positioned(
                left: 150,
                top: 210,
                child: Container(
                  width: 110,
                  height: 120,
                  child: SvgPicture.asset(
                    'assets/icon_userbox.svg',  // SVG 아이콘 표시
                    width: 100,  // 아이콘 크기 설정
                    height: 110,  // 아이콘 크기 설정
                  ),
                ),
              ),
              Positioned(
                left: 231,
                top: 444,
                child: Container(
                  width: 60,
                  height: 60,
                  child: SvgPicture.asset(
                    'assets/icon_book.svg',  // SVG 아이콘 표시
                    width: 48,  // 아이콘 크기 설정
                    height: 48,  // 아이콘 크기 설정
                  ),
                ),
              ),
              Positioned(
                left: 20,
                top: 477,
                child: SizedBox(
                  width: 210,
                  child: Text(
                    '나의 미술관',
                    style: TextStyle(
                      color: const Color(0xFFD55E00),
                      fontSize: 40,  // 폰트 크기를 크게 수정
                      fontFamily: 'KoddiUD OnGothic',
                      fontWeight: FontWeight.w700,
                      height: 1.0,  // 텍스트의 줄 간격을 1로 설정
                      letterSpacing: 0.25,
                    ),
                  ),
                ),
              ),
              // Button 1
              Positioned(
                left: 136,
                top: 633,
                child: Container(
                  width: 218,
                  height: 39,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD55E00),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: const Color(0xFFD55E00),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '2025. 02. 09',
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
              ),
              // Button 2
              Positioned(
                left: 136,
                top: 549,
                child: Container(
                  width: 218,
                  height: 39,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD55E00),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: const Color(0xFFD55E00),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '2025. 02. 12',
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
              ),
              // Button 3
              Positioned(
                left: 136,
                top: 720,
                child: Container(
                  width: 218,
                  height: 39,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD55E00),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: const Color(0xFFD55E00),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '2025. 02. 07',
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
              ),
              // More button
              Positioned(
                left: 161,
                top: 807,
                child: Container(
                  width: 100,
                  height: 39,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD55E00),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      width: 1,
                      color: const Color(0xFFD55E00),
                    ),
                  ),
                  child: Center(
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
              ),
            ],
          ),
        ),
      ],
    );
  }
}
