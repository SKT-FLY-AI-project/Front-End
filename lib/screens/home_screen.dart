import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'camera_screen.dart';
import 'mypage_screen.dart';
import 'recommand_screen.dart';
import 'tabbed_screen.dart';
import 'diary_screen.dart';
import '../services/auth_service.dart';
import '../config/app_config.dart';

// 작품 모델 클래스 추가
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
      title: json['title'] ?? '제목 없음',
      artist: json['artist'] ?? '작자 미상',
      richDescription: json['rich_description'] ?? '설명 없음',
      date: DateTime.parse(json['created_at']),
      conversationId: json['conversation_id'],
    );
  }
}

// 작품 레포지토리 클래스 추가
class ArtworkRepository {
  static final AppConfig _config = AppConfig();

  // 최근 대화 목록 가져오기 (최대 5개)
  static Future<List<ArtworkModel>> getRecentConversations() async {
    String? userId = await AuthService.getUserId();

    try {
      String url = '${_config.apiUrl}/chat/$userId?limit=2';

      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data =
        jsonDecode(utf8.decode(response.bodyBytes));
        final List<dynamic> conversationsJson = data['conversations'] ?? [];
        return conversationsJson
            .map((json) => ArtworkModel.fromJson(json))
            .toList();
      } else {
        print('최근 대화 목록 조회 실패: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      print('최근 대화 목록 조회 중 오류 발생: $e');
      return [];
    }
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String? token;
  bool isLoading = true;
  List<ArtworkModel> recentConversations = []; // 최근 대화 목록

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadRecentConversations(); // 최근 대화 목록 로드
  }

  Future<void> _loadUserData() async {
    // AuthService를 통해 토큰 불러오기
    token = await AuthService.getToken();

    setState(() {
      isLoading = false;
    });
  }

  // 최근 대화 목록 로드 함수 추가
  Future<void> _loadRecentConversations() async {
    try {
      final conversations = await ArtworkRepository.getRecentConversations();
      setState(() {
        recentConversations = conversations;
      });
    } catch (e) {
      print('최근 대화 목록 로드 중 오류: $e');
    }
  }

  // 대화 상세 화면으로 이동하는 함수 추가
  void _openArtworkDetail(ArtworkModel artwork) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TabbedScreen(
          imageUrl: artwork.imageUrl,
          title: artwork.title,
          artist: artwork.artist,
          richDescription: artwork.richDescription,
          conversationId: artwork.conversationId,
        ),
      ),
    ).then((_) {
      // 화면으로 돌아왔을 때 최신 데이터로 갱신
      _loadRecentConversations();
    });
  }

  // 작품 카드 위젯 추가
  Widget _buildArtworkCard(ArtworkModel artwork) {
    return Semantics(
      label:
      '작품 카드. 제목 ${artwork.title}, 작가 ${artwork.artist}, 날짜 ${DateFormat('yyyy.MM.dd').format(artwork.date)}. 자세한 정보를 보려면 터치하세요.',
      button: true,
      child: GestureDetector(
        onTap: () => _openArtworkDetail(artwork),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 작품 이미지
              ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
                child: Image.network(
                  artwork.imageUrl,
                  width: double.infinity,
                  height: 150,
                  fit: BoxFit.cover,
                  semanticLabel: '작품 이미지: ${artwork.title}',
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.image_not_supported,
                            size: 40, color: Colors.grey),
                      ),
                    );
                  },
                ),
              ),
              // 작품 정보
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      artwork.title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E40AF),
                        letterSpacing: -0.5,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            artwork.artist,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          DateFormat('yyyy.MM.dd').format(artwork.date),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          '자세히 보기',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 12,
                          color: Colors.blue[700],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
        appBar: AppBar(
          title: FittedBox(
            fit: BoxFit.scaleDown,
            child: Semantics(
              label: '아트 케미',
              child: const Text(
                'ArtChemy',
                style: TextStyle(
                  color: Color(0xFF1E40AF),
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ),
          ),
          centerTitle: false,
          backgroundColor: Colors.grey[50],
          elevation: 0,
          actions: [
            Container(
              margin: const EdgeInsets.only(right: 12),
              child: IconButton(
                tooltip: '마이 페이지',
                icon: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 18,
                    backgroundColor: Colors.transparent,
                    child: Icon(Icons.person,
                        color: Color(0xFF1E40AF), size: 26),
                  ),
                ),
                onPressed: () {
                  if (token != null) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => MyPageScreen(),
                      ),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content:
                        Text('토큰이 없습니다. 다시 로그인 해주세요.'),
                        backgroundColor: Color(0xFF1E40AF),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
              ),
            ),
          ],
        ),
        backgroundColor: Colors.grey[50],
        body: RefreshIndicator(
          onRefresh: _loadRecentConversations,
          color: Color(0xFF1E40AF),
          backgroundColor: Colors.white,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 작품 감상하기 버튼
                  Semantics(
                    label: '작품 감상하기 버튼. AI 설명을 듣기 위해 카메라를 실행합니다.',
                    button: true,
                    child: GestureDetector(
                      onTap: () async {
                        final cameras = await availableCameras(); // 카메라 목록 가져오기
                        if (cameras.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => CameraScreen(camera: cameras.first)),
                          ).then((_) {
                            _loadRecentConversations();
                          });
                        } else {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                title: const Text(
                                  '알림',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1E40AF),
                                  ),
                                ),
                                content: const Text(
                                  '카메라를 찾을 수 없습니다.',
                                  textAlign: TextAlign.center,
                                ),
                                actionsAlignment: MainAxisAlignment.center,
                                actions: [
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF1E40AF),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: const Text(
                                      '확인',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ),
                                ],
                              );
                            },
                          );
                        }
                      },
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                        constraints: const BoxConstraints(minHeight: 130),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFF1E40AF), Color(0xFF2563EB)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Color(0xFF1E40AF).withOpacity(0.4),
                              blurRadius: 12,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 70,
                              height: 70,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Center(
                                child: Icon(
                                  Icons.camera_alt_rounded,
                                  color: Colors.white,
                                  size: 36,
                                ),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '작품 감상하기',
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: const Text(
                                          'AI 설명',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      const Icon(
                                        Icons.arrow_forward,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: const Text(
                            '최근 감상한 작품',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black87,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ),
                        Semantics(
                          label: '더보기 버튼. 최근 감상한 작품 목록을 더 확인합니다.',
                          button: true,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => DiaryPage()),
                              ).then((_) {
                                _loadRecentConversations();
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: const Color(0xFF1E40AF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Text(
                                '더보기',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  // 최근 대화 목록 (Empty 일 경우와 데이터가 있을 경우 모두 Column으로 구성)
                  recentConversations.isEmpty
                      ? Container(
                    width: double.infinity,
                    height: 200,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 10,
                          spreadRadius: 0,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.art_track,
                          size: 48,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '최근 감상한 작품이 없습니다.',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.black54,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '카메라로 작품을 찍어 AI 설명을 들어보세요',
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                      : Column(
                    children: recentConversations
                        .map((artwork) => _buildArtworkCard(artwork))
                        .toList(),
                  ),
                  const SizedBox(height: 20),
                  // 오늘의 명화 추천 버튼
                  Semantics(
                    label:
                    '오늘의 명화 추천 버튼. 세계적으로 유명한 명화의 설명을 들어보세요.',
                    button: true,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const RecommandScreen()),
                        );
                      },
                      child: Container(
                        width: double.infinity,
                        height: 130,
                        decoration: BoxDecoration(
                          image: const DecorationImage(
                            image: AssetImage('assets/recommand_img.png'),
                            fit: BoxFit.cover,
                            colorFilter: ColorFilter.mode(
                              Color(0xFF1E3A8A),
                              BlendMode.overlay,
                            ),
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        alignment: Alignment.center,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                Colors.black.withOpacity(0.7),
                                Colors.transparent,
                              ],
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.3),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.auto_awesome,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          '오늘의 명화 추천',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                        SizedBox(height: 4),
                                        Text(
                                          '세계적으로 유명한 명화의 설명을 들어보세요',
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        )
    );
  }
}