import 'package:flutter/material.dart';
import 'vts_screen.dart';
import '../services/tts_service.dart';

class RecommandScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String artist;
  final String richDescription;
  final List<List<int>> dominantColors;

  const RecommandScreen({
    Key? key,
    this.imageUrl =
    'https://artchemy-media.s3.ap-southeast-2.amazonaws.com/static/pictop.png',
    this.title = '별이 빛나는 밤',
    this.artist = '빈센트 반 고흐, 1889',
    this.richDescription =
    "이 작품은 후기 인상주의를 대표하는 걸작으로, 소용돌이치는 하늘과 밝게 빛나는 별들이 특징적입니다. 강렬한 감정 표현과 역동적인 붓터치를 통해 작가의 내면 세계를 드러내고 있습니다.",
    this.dominantColors = const [
      [0, 0, 0],
      [255, 255, 255]
    ],
  }) : super(key: key);

  @override
  _RecommandScreenState createState() => _RecommandScreenState();
}

class _RecommandScreenState extends State<RecommandScreen> {
  final TTSService ttsService = TTSService();

  @override
  Widget build(BuildContext context) {
    // WillPopScope로 감싸 안드로이드 물리적 뒤로가기 버튼 누를 때 ttsService.stop() 호출
    return WillPopScope(
      onWillPop: () async {
        await ttsService.stop();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '오늘의 작품',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.black,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              ttsService.stop();
              Navigator.pop(context);
            },
          ),
        ),
        backgroundColor: Colors.black,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 작품 메인 이미지 (고정 높이 지정)
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  widget.imageUrl,
                  width: double.infinity,
                  height: 300,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 16),
              // 작가 초상화 + 작품 제목 및 작가 정보
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.asset(
                      'assets/vangogh.jpg',
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        ttsService.speak("${widget.title}, ${widget.artist}");
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              widget.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.artist,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // AI 분석 결과 (클릭 시 TTS 실행)
              GestureDetector(
                onTap: () {
                  ttsService.speak(widget.richDescription);
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'AI 분석결과',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.richDescription,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // 대화하기 버튼 - VtsScreen으로 이동하며 변수 전달
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VtsScreen(
                          imageUrl: widget.imageUrl,
                          title: widget.title,
                          artist: widget.artist,
                          richDescription: widget.richDescription,
                          dominantColors: widget.dominantColors,
                          conversationId: 'conversation_example',
                          initialMessages: [
                            {'role': 'system', 'message': '안녕하세요!'}
                          ],
                        ),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E40AF),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                  child: const Text(
                    '대화하기',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
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
