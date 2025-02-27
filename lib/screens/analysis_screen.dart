import 'package:ArtChemy/screens/diary_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'vts_screen.dart';
import '../services/tts_service.dart'; // Google Cloud TTS 서비스 추가
import '../config/app_config.dart';
import '../services/auth_service.dart';

class AnalysisScreen extends StatefulWidget {
  static final AppConfig _config = AppConfig();

  final String imageUrl;
  final String title;
  final String artist;
  final String? vlmDescription;
  final String richDescription;
  final List<List<int>>? dominantColors;
  final String? audioUrl;

  AnalysisScreen({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.artist,
    this.vlmDescription,
    required this.richDescription,
    this.dominantColors,
    this.audioUrl,
  }) : super(key: key);

  @override
  _AnalysisScreenState createState() => _AnalysisScreenState();
}

class _AnalysisScreenState extends State<AnalysisScreen> {
  final TTSService ttsService = TTSService();

  // 텍스트 읽기 함수
  Future<void> _speak(String text) async {
    await ttsService.speak(text);
  }

  // 이미지 다이얼로그
  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 1.0,
            maxScale: 3.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(widget.imageUrl),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    // 화면 종료 시 TTS 종료
    ttsService.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // WillPopScope를 사용해 물리적 뒤로가기 버튼 눌림 이벤트를 가로챕니다.
    return WillPopScope(
      onWillPop: () async {
        ttsService.stop();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: const Text(
            'AI 작품분석',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFF5F5F5),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.black),
            onPressed: () {
              ttsService.stop();
              Navigator.pop(context);
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => _showImageDialog(context),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(widget.imageUrl, width: double.infinity, fit: BoxFit.cover),
                  ),
                ),
                const SizedBox(height: 12),
                GestureDetector(
                  onTap: () => _speak("제목, ${widget.title}. 작가, ${widget.artist}."),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.artist,
                            style: const TextStyle(fontSize: 14, color: Color(0xFF1E40AF)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GestureDetector(
                  onTap: () => _speak("AI 분석 결과입니다. ${widget.richDescription}"),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF1E40AF), width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 5,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AI 분석결과',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          widget.richDescription,
                          style: const TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          final payload = {
                            "request": "save",
                            "image_url": widget.imageUrl,
                            "title": widget.title,
                            "artist": widget.artist,
                            "rich_description": widget.richDescription,
                          };
                          String? userId = await AuthService.getUserId();
                          final response = await http.post(
                            Uri.parse("${AnalysisScreen._config.apiUrl}/chat/$userId/create"),
                            headers: {"Content-Type": "application/json"},
                            body: jsonEncode(payload),
                          );
                          if (response.statusCode == 200) {
                            print("감상 저장 성공: ${response.body}");
                          } else {
                            print("감상 저장 실패: ${response.statusCode}");
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E40AF),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: const Text(
                          '감상 저장하기',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10), // 버튼 간격 조정
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => VtsScreen(
                              imageUrl: widget.imageUrl,
                              title: widget.title,
                              artist: widget.artist,
                              richDescription: widget.richDescription,
                              dominantColors: widget.dominantColors,
                            )),
                          );
                        },
                        style: OutlinedButton.styleFrom(
                          foregroundColor: const Color(0xFF1E40AF),
                          side: const BorderSide(color: Color(0xFF1E40AF)),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        ),
                        child: const Text(
                          '대화하기',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
