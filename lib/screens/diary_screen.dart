import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'conversation_detail_screen.dart';
import 'conversation_history_screen.dart';
import 'tabbed_screen.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';

// 서버 API에 맞춘 작품 모델 클래스
class ArtworkModel {
  final String imageUrl;
  final String title;
  final String artist;
  final DateTime date;
  final String richDescription;
  final String conversationId;

  ArtworkModel({
    required this.imageUrl,
    required this.title,
    required this.artist,
    required this.date,
    required this.richDescription,
    required this.conversationId,
  });

  factory ArtworkModel.fromJson(Map<String, dynamic> json) {
    return ArtworkModel(
      imageUrl: json['image_url'] ?? 'pictop.png',
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      richDescription: json['rich_description'] ?? '',
      date: DateTime.parse(json['created_at']),
      conversationId: json['conversation_id'],
    );
  }
}

// FastAPI와 연동하는 저장소 클래스
class ArtworkRepository {
  static final AppConfig _config = AppConfig();

  static Future<List<ArtworkModel>> getArtworksByDate(DateTime date) async {
    String? userId = await AuthService.getUserId();
    try {
      String formattedDate = DateFormat('yyyy-MM-dd').format(date);
      final response = await http.get(
        Uri.parse('${_config.apiUrl}/chat/$userId?date=$formattedDate'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> conversationsJson = data['conversations'] ?? [];
        return conversationsJson.map((json) => ArtworkModel.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }

  // 대화 목록 조회 API 호출 (title 파라미터는 검색 필터링용)
  static Future<List<ArtworkModel>> getConversations({DateTime? date, String? title}) async {
    String? userId = await AuthService.getUserId();

    try {
      String url = '${_config.apiUrl}/chat/$userId';

      // date 파라미터가 있으면 추가
      if (date != null) {
        String formattedDate = DateFormat('yyyy-MM-dd').format(date);
        url += '?date=$formattedDate';

        // title 파라미터가 있으면 &로 연결
        if (title != null && title.isNotEmpty) {
          url += '&title=$title';
        }
      } else if (title != null && title.isNotEmpty) {
        // date가 없고 title만 있는 경우
        url += '?title=$title';
      }

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> conversationsJson = data['conversations'] ?? [];
        return conversationsJson
            .map((json) => ArtworkModel.fromJson(json))
            .toList();
      } else {
        print('대화 목록 조회 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('대화 목록 조회 중 오류 발생: $e');
      return [];
    }
  }
}

class DiaryPage extends StatefulWidget {
  const DiaryPage({super.key});

  @override
  State<DiaryPage> createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  DateTime selectedDate = DateTime.now();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  String _searchText = "찾으시는 작품 있으세요?";
  bool _isLoading = false;
  final TextEditingController _textController = TextEditingController();
  List<ArtworkModel> _artworks = [];

  @override
  void initState() {
    super.initState();
    _initSpeech();
    _loadArtworksForSelectedDate();
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  // 텍스트 입력 검색 처리
  Future<void> _handleTextSubmit() async {
    String query = _textController.text.trim();
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
      _searchText = "검색 중...";
    });

    try {
      // 검색어와 일치하는 제목의 대화만 가져오기
      List<ArtworkModel> conversations = await ArtworkRepository.getConversations(
          date: selectedDate,
          title: query
      );

      setState(() {
        _artworks = conversations;
        _isLoading = false;
      });
    } catch (e) {
      print('API 검색 중 오류 발생: $e');
      setState(() {
        _isLoading = false;
      });
    }

    _textController.clear();
  }

  // 음성 인식 초기화
  Future<void> _initSpeech() async {
    var micStatus = await Permission.microphone.request();
    var speechStatus = await Permission.speech.request();

    if (micStatus.isGranted && speechStatus.isGranted) {
      try {
        bool available = await _speech.initialize(
          onStatus: (status) {
            print('음성 인식 상태: $status');
            if (status == 'done' || status == 'notListening') {
              setState(() {
                _isListening = false;
              });
            }
          },
          onError: (errorNotification) {
            print('음성 인식 오류: $errorNotification');
            setState(() {
              _isListening = false;
            });
            _showErrorDialog("음성 인식 중 오류가 발생했습니다.");
          },
        );

        if (!available) {
          _showErrorDialog(
              "음성 인식을 사용할 수 없습니다. 기기 설정을 확인해주세요.");
        }
      } catch (e) {
        _showErrorDialog("음성 인식을 초기화할 수 없습니다.");
      }
    } else {
      _showErrorDialog(
          "음성 인식을 위해 마이크 권한이 필요합니다. 설정에서 권한을 허용해주세요.");
    }
  }

  // 음성 인식 시작
  void _startVoiceRecognition() async {
    var micStatus = await Permission.microphone.status;
    var speechStatus = await Permission.speech.status;

    if (micStatus.isGranted && speechStatus.isGranted) {
      try {
        setState(() {
          _isListening = true;
          _searchText = "듣고 있어요...";
        });

        _speech.listen(
          onResult: (result) {
            setState(() {
              _searchText = result.recognizedWords;
            });

            if (result.finalResult) {
              _stopVoiceRecognition();
              _searchConversationByVoice(result.recognizedWords);
            }
          },
          localeId: 'ko_KR',
          cancelOnError: true,
          partialResults: true,
        );
      } catch (e) {
        _showErrorDialog("음성 인식 중 오류가 발생했습니다.");
        setState(() {
          _isListening = false;
          _searchText = "찾으시는 작품 있으세요?";
        });
      }
    } else {
      _showErrorDialog(
          "음성 인식을 위해 마이크 권한이 필요합니다. 설정에서 권한을 허용해주세요.");
    }
  }

  // 음성 인식 중지
  void _stopVoiceRecognition() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  // 음성 인식 결과로 대화 검색
  Future<void> _searchConversationByVoice(String query) async {
    setState(() {
      _isLoading = true;
      _searchText = "검색 중...";
    });

    try {
      // 검색어와 일치하는 제목의 대화만 가져오기
      List<ArtworkModel> conversations = await ArtworkRepository.getConversations(
          date: selectedDate,
          title: query
      );

      setState(() {
        _artworks = conversations;
        _isLoading = false;
      });
    } catch (e) {
      print('API 검색 중 오류 발생: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // 오류 다이얼로그 표시
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('알림'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }

  Future<void> _loadArtworksForSelectedDate() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final artworksForDate = await ArtworkRepository.getArtworksByDate(selectedDate);
      setState(() {
        _artworks = artworksForDate;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _changeDate(bool isNext) {
    setState(() {
      selectedDate = isNext
          ? selectedDate.add(const Duration(days: 1))
          : selectedDate.subtract(const Duration(days: 1));
    });
    _loadArtworksForSelectedDate();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );

    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _loadArtworksForSelectedDate();
    }
  }

  void _openTabbedScreen(ArtworkModel artwork) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TabbedScreen(
          imageUrl: artwork.imageUrl,
          title: artwork.title ?? "제목 없음",
          artist: artwork.artist ?? "작자 미상",
          // vlmDescription: null, // 기본값 처리됨
          richDescription: artwork.richDescription,
          // dominantColors: [],
          // audioUrl: "",
          conversationId: artwork.conversationId,
        ),
      ),
    );
  }

  Widget _buildArtworkCard(BuildContext context, ArtworkModel artwork) {
    return GestureDetector(
      onTap: () => _openTabbedScreen(artwork),
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
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                artwork.imageUrl,
                width: double.infinity,
                height: 200,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: double.infinity,
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Text(
                artwork.title,
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
      ),
    );
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
          onPressed: () => Navigator.pop(context),
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
        actions: [
          IconButton(
            // icon: const Icon(Icons.history, color: Colors.black),
            // onPressed: () {
            //   Navigator.push(
            //     context,
            //     MaterialPageRoute(
            //       builder: (context) => ConversationHistoryScreen(),
            //     ),
            //   );
            // },
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _isLoading
              ? null
                  : () {
                _loadArtworksForSelectedDate();
                },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () => _changeDate(false),
                  child: const Icon(Icons.chevron_left, size: 32, color: Colors.black),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _selectDate(context),
                  child: Text(
                    DateFormat('yyyy.MM.dd').format(selectedDate),
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E40AF),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                GestureDetector(
                  onTap: () => _changeDate(true),
                  child: const Icon(Icons.chevron_right, size: 32, color: Colors.black),
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFF1E40AF)))
                : _artworks.isEmpty
                ? const Center(child: Text("이 날짜에 등록된 작품이 없습니다."))
                : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _artworks.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildArtworkCard(context, _artworks[index]),
                );
              },
            ),
          ),

          // 텍스트 입력 및 음성 검색 영역
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 4,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: InputDecoration(
                      hintText: '제목을 입력하세요',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    style: const TextStyle(
                      color: Colors.black87,
                      fontSize: 16,
                    ),
                    onSubmitted: (_) => _handleTextSubmit(),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: _isLoading
                      ? null
                      : (_isListening ? _stopVoiceRecognition : _startVoiceRecognition),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isLoading
                          ? Colors.grey
                          : (_isListening ? Colors.red : const Color(0xFF1E40AF)),
                    ),
                    child: const Icon(
                      Icons.mic,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _isLoading ? null : _handleTextSubmit,
                  color: const Color(0xFF1E40AF),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}