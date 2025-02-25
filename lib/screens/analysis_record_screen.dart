import 'package:ArtChemy/screens/diary_screen.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'dart:convert';
import 'vts_screen.dart';
import '../services/tts_service.dart'; // Google Cloud TTS 서비스 추가
import '../config/app_config.dart';
import '../services/auth_service.dart';

class AnalysisRecordScreen extends StatefulWidget {
  final String conversationId;
  final String imageUrl;
  final String title;
  final String artist;
  final String? vlmDescription;
  final String richDescription;
  final List<List<int>>? dominantColors;
  final String? audioUrl;

  AnalysisRecordScreen({
    Key? key,
    required this.conversationId,
    required this.imageUrl,
    required this.title,
    required this.artist,
    this.vlmDescription,
    required this.richDescription,
    this.dominantColors,
    this.audioUrl,
  }) : super(key: key);

  @override
  _AnalysisRecordScreenState createState() => _AnalysisRecordScreenState();
}

class _AnalysisRecordScreenState extends State<AnalysisRecordScreen> {
  final TTSService ttsService = TTSService();
  static final AppConfig _config = AppConfig();

  @override
  void dispose() {
    // 화면 종료 시 TTS 중지
    ttsService.stop();
    super.dispose();
  }

  // 텍스트 읽어주는 함수 (Google Cloud TTS 적용)
  Future<void> _speak(String text) async {
    await ttsService.speak(text);
  }

  Future<void> _showDeleteConfirmationDialog(BuildContext context, String conversationId) async {
    final confirm = await showDialog<bool>(
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
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.delete_rounded,
                    color: Colors.red[400],
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  '삭제 확인',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  '정말로 삭제하시겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 28),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              '취소',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              '삭제하기',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      await deleteConversation(conversationId);
    }
  }

  Future<void> deleteConversation(String conversationId) async {
    String? userId = await AuthService.getUserId();
    final url = Uri.parse('${_config.apiUrl}/chat/$conversationId/delete?userid=$userId');

    try {
      final response = await http.delete(url);
      if (response.statusCode == 200) {
        print('대화 삭제 성공');

        if (mounted) {
          Navigator.pop(context); // 다이얼로그 닫기
          Navigator.pop(context); // 이전 화면으로 이동
        }
      } else {
        print('대화 삭제 실패: ${response.statusCode}');
      }
    } catch (error) {
      print('오류 발생: $error');
    }
  }

  void _showImageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: InteractiveViewer(
            panEnabled: true,
            boundaryMargin: const EdgeInsets.all(20),
            minScale: 1,
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
  Widget build(BuildContext context) {
    // WillPopScope를 사용해 안드로이드 물리적 뒤로가기 버튼 눌림 시 TTS 종료
    return WillPopScope(
      onWillPop: () async {
        ttsService.stop();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
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
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 150,
                    child: ElevatedButton(
                      onPressed: () async {
                        await _showDeleteConfirmationDialog(context, widget.conversationId);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text('삭제하기', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
