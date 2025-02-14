import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';  // flutter_svg를 사용하기 위한 import

void main() {
  runApp(const FigmaToCodeApp());
}

class FigmaToCodeApp extends StatelessWidget {
  const FigmaToCodeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
      ),
      home: Scaffold(
        body: ListView(
          children: [
            Container(
              width: 412,
              height: 892,
              child: Stack(
                children: [
                  Positioned(
                    left: 116,
                    top: 457,
                    child: Text(
                      'Art Teller',
                      style: TextStyle(
                        color: Color(0xFFD55E00),
                        fontSize: 40,
                        fontFamily: 'KoddiUD OnGothic',
                        fontWeight: FontWeight.w700,
                        height: 0.50,
                        letterSpacing: 0.25,
                      ),
                    ),
                  ),
                  Positioned(
                    left: 150,
                    top: 299,
                    child: Container(
                      width: 112,
                      height: 131,
                      child: SvgPicture.asset(
                        'assets/MIC_ICON.svg',  // SVG 아이콘 표시
                        width: 112,  // 아이콘 크기 설정
                        height: 131,  // 아이콘 크기 설정
                      ),
                    ),
                  ),
                  Positioned(
                    left: 123,
                    top: 500,
                    child: Container(
                      width: 166,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 123,
                    top: 500,
                    child: Container(
                      width: 110,
                      decoration: ShapeDecoration(
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                            width: 1,
                            strokeAlign: BorderSide.strokeAlignCenter,
                            color: Color(0xFFD55E00),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
