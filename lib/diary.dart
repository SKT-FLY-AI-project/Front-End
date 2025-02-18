import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';  // 날짜 포맷을 위한 패키지
import 'mypage.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const DiaryPage(),
    );
  }
}

// StatefulWidget으로 변경
class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  DateTime selectedDate = DateTime.now();  // 선택된 날짜 저장

  // 날짜 선택 다이얼로그를 보여주는 함수
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF1E40AF),    // 달력의 주요 색상
              onPrimary: Colors.white,       // 선택된 날짜의 텍스트 색상
              onSurface: Colors.black,       // 달력의 텍스트 색상
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF1E40AF), // 버튼 텍스트 색상
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const MyPageScreen()),
            );
          },
        ),
        title: const Text(
          "감상 일기",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // 날짜 네비게이션
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/left_icon.svg',
                  width: 14,
                  height: 14,
                ),
                const SizedBox(width: 16),
                Row(
                  children: [
                    Text(
                      DateFormat('yyyy.MM.dd').format(selectedDate),  // 선택된 날짜 표시
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(  // 캘린더 아이콘을 탭할 수 있게 만듦
                      onTap: () => _selectDate(context),
                      child: SvgPicture.asset(
                        'assets/calender_icon.svg',
                        width: 20,
                        height: 20,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 16),
                SvgPicture.asset(
                  'assets/right_icon.svg',
                  width: 14,
                  height: 14,
                ),
              ],
            ),
          ),
          // 작품 이미지 및 제목 카드들
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildArtworkCard(
                    context,
                    'pictop.png',
                    '별이 빛나는 밤',
                  ),
                  const SizedBox(height: 24),
                  _buildArtworkCard(
                    context,
                    'picbot.png',
                    '사이프러스가 있는 밀밭',
                  ),
                ],
              ),
            ),
          ),
          // 하단 페이지 네비게이션
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  'assets/left_icon.svg',
                  width: 14,
                  height: 14,
                ),
                const SizedBox(width: 16),
                const Text(
                  "1",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(width: 16),
                SvgPicture.asset(
                  'assets/right_icon.svg',
                  width: 14,
                  height: 14,
                ),
              ],
            ),
          ),
          // 하단 입력창
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                  color: const Color(0xFFE5E7EB),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  const Expanded(
                    child: Text(
                      "찾으시는 작품 있으세요?",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black54,
                      ),
                    ),
                  ),
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF1E40AF),
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkCard(BuildContext context, String imagePath, String title) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF1E40AF),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.width * 0.5,
            child: ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              child: Image.asset(
                'assets/$imagePath',
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: const BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Color(0xFF1E40AF),
                  width: 1,
                ),
              ),
            ),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1E40AF),
              ),
            ),
          ),
        ],
      ),
    );
  }
}