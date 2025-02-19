import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
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
  
  final List<Map<String, String>> _artworks = [
    {'title': '별이 빛나는 밤', 'imagePath': 'pictop.png'},
    {'title': '사이프러스가 있는 밀밭', 'imagePath': 'picbot.png'},
  ];

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

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
          _showErrorDialog("음성 인식을 사용할 수 없습니다. 기기 설정을 확인해주세요.");
        }
      } catch (e) {
        _showErrorDialog("음성 인식을 초기화할 수 없습니다.");
      }
    } else {
      _showErrorDialog("음성 인식을 위해 마이크 권한이 필요합니다. 설정에서 권한을 허용해주세요.");
    }
  }

  void _toggleListening() async {
    if (!_isListening) {
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
                
                _searchArtwork(_searchText);

                if (result.finalResult) {
                  _isListening = false;
                  _speech.stop();
                }
              });
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
        _showErrorDialog("음성 인식을 위해 마이크 권한이 필요합니다. 설정에서 권한을 허용해주세요.");
      }
    } else {
      setState(() {
        _isListening = false;
        _searchText = "찾으시는 작품 있으세요?";
      });
      _speech.stop();
    }
  }

  void _searchArtwork(String query) {
    var matchedArtworks = _artworks.where((artwork) => 
      artwork['title']!.contains(query)
    ).toList();

    setState(() {
      if (matchedArtworks.isNotEmpty) {
        _searchText = "'$query'에 대한 검색 결과: ${matchedArtworks.length}개 작품";
      } else {
        _searchText = "작품을 찾을 수 없음";
      }
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('음성 인식'),
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
              primary: Color(0xFF1E40AF),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Color(0xFF1E40AF),
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
                      DateFormat('yyyy.MM.dd').format(selectedDate),
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF1E40AF),
                      ),
                    ),
                    const SizedBox(width: 12),
                    GestureDetector(
                      onTap: () => _selectDate(context),
                      child: Padding(
                        padding: const EdgeInsets.only(right: 4),
                        child: SvgPicture.asset(
                          'assets/calender_icon.svg',
                          width: 24,
                          height: 24,
                        ),
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
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // 작품을 찾지 못했을 때 표시할 위젯
                  if (_searchText == "작품을 찾을 수 없음")
                    Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          "작품을 찾을 수 없음",
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),

                  // 기존 작품 리스트 렌더링
                  ...(_searchText != "작품을 찾을 수 없음" 
                    ? _artworks.map((artwork) => 
                        Column(
                          children: [
                            const SizedBox(height: 16),
                            _buildArtworkCard(
                              context,
                              artwork['imagePath']!,
                              artwork['title']!,
                            ),
                            const SizedBox(height: 24),
                          ],
                        )
                      ).toList()
                    : [])
                ],
              ),
            ),
          ),
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
                  Expanded(
                    child: Text(
                      _searchText,
                      style: TextStyle(
                        fontSize: 16,
                        color: _isListening ? Colors.black : Colors.black54,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: _toggleListening,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: _isListening 
                          ? Colors.red 
                          : const Color(0xFF1E40AF),
                      ),
                      child: Icon(
                        _isListening ? Icons.stop : Icons.mic,
                        color: Colors.white,
                      ),
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