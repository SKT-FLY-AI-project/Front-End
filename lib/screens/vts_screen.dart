import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/tts_service.dart'; // TTS 서비스 추가

// 수정된 VtsScreen
class VtsScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String artist;
  final String richDescription;
  final List<List<int>>? dominantColors;
  final String? conversationId;
  final List<Map<String, String>>? initialMessages;

  const VtsScreen({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.artist,
    required this.richDescription,
    this.dominantColors,
    this.conversationId,
    this.initialMessages,
  }) : super(key: key);

  @override
  _VtsScreenState createState() => _VtsScreenState();
}

class _VtsScreenState extends State<VtsScreen> {
  static final AppConfig _config = AppConfig();

  final stt.SpeechToText _speech = stt.SpeechToText();
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isListening = false;
  String _text = "";
  bool _isLoading = false;
  String? _currentConversationId;

  // 웹소켓 채널 객체
  WebSocketChannel? _channel;

  // 대화 목록
  List<Map<String, String>> conversation = [];

  // TTS 서비스 인스턴스
  final TTSService ttsService = TTSService();

  // TTS 음소거 상태 (true이면 음소거)
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();

    // 초기 메시지가 있다면 불러오기
    if (widget.initialMessages != null && widget.initialMessages!.isNotEmpty) {
      _prepareInitialMessages();
      // 다음 프레임에서 스크롤 위치 조정
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    }

    _currentConversationId = widget.conversationId;
    _connectWebSocket();
  }

  void _prepareInitialMessages() {
    conversation = [];
    int i = 0;

    while (i < widget.initialMessages!.length) {
      if (widget.initialMessages![i]["role"] == "user") {
        String userMessage = widget.initialMessages![i]["content"] ?? "";
        String assistantResponse = "";

        // 다음 메시지가 assistant인지 확인
        if (i + 1 < widget.initialMessages!.length &&
            widget.initialMessages![i + 1]["role"] == "assistant") {
          assistantResponse = widget.initialMessages![i + 1]["content"] ?? "";
          i += 2; // 두 메시지 모두 처리했으므로 인덱스를 2 증가
        } else {
          i += 1; // 사용자 메시지만 처리했으므로 인덱스를 1 증가
        }

        conversation.add({
          "question": userMessage,
          "response": assistantResponse
        });
      } else {
        // 만약 첫 메시지가 assistant면, 빈 사용자 메시지로 처리
        if (i == 0 && widget.initialMessages![i]["role"] == "assistant") {
          conversation.add({
            "question": "",
            "response": widget.initialMessages![i]["content"] ?? ""
          });
        }
        i += 1;
      }
    }
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // 웹소켓 연결 설정
  void _connectWebSocket() async {
    String? userId = await AuthService.getUserId();
    try {
      _channel = IOWebSocketChannel.connect('${_config.wsUrl}/chat/$userId');
      _channel!.stream.listen(
            (message) {
          final responseData = jsonDecode(message);
          if (responseData['message_type'] == 'chat_response') {
            if (!mounted) return;
            setState(() {
              if (conversation.isNotEmpty) {
                conversation.last["response"] =
                    responseData['response'] ?? "응답을 받지 못했습니다.";
              }
              _currentConversationId = responseData['conversation_id'];
              _isLoading = false;
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });
            });
          }
        },
        onError: (error) {
          print('웹소켓 오류: $error');
          if (!mounted) return;
          setState(() {
            if (conversation.isNotEmpty) {
              conversation.last["response"] = "웹소켓 연결 오류가 발생했습니다.";
            }
            _isLoading = false;
          });
          Future.delayed(const Duration(seconds: 3), () {
            if (mounted) _connectWebSocket();
          });
        },
        onDone: () {
          print('웹소켓 연결 종료');
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) _connectWebSocket();
          });
        },
      );

      // 연결 후 5초마다 ping 메시지 전송 (연결 유지)
      _startPingTimer();
    } catch (e) {
      print('웹소켓 연결 실패: $e');
    }
  }

  void _startPingTimer() {
    Future.delayed(const Duration(seconds: 5), () {
      if (_channel != null) {
        try {
          _channel!.sink.add(jsonEncode({"message_type": "ping"}));
          _startPingTimer();
        } catch (e) {
          print('Ping 전송 실패: $e');
        }
      }
    });
  }

  void _sendMessageToServer(String message) {
    if (_channel == null || _isLoading) return;

    setState(() => _isLoading = true);

    try {
      final Map<String, dynamic> requestData = {
        "message_type": "chat",
        "request": message,
        "title": widget.title,
        "image_url": widget.imageUrl,
        "rich_description": widget.richDescription,
        "dominant_colors": widget.dominantColors,
        "conversation_id": _currentConversationId
      };

      _channel!.sink.add(jsonEncode(requestData));

      // 메시지를 보낸 후 스크롤 위치 조정
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scrollToBottom();
      });
    } catch (e) {
      setState(() {
        if (conversation.isNotEmpty) {
          conversation.last["response"] = "메시지 전송 오류가 발생했습니다.";
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _startVoiceRecognition() async {
    bool available = await _speech.initialize(
      onStatus: (status) => print('STT 상태: $status'),
      onError: (error) => print('STT 오류: $error'),
    );

    if (available) {
      setState(() => _isListening = true);
      _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        },
      );
    }
  }

  void _stopVoiceRecognition() {
    _speech.stop();
    setState(() => _isListening = false);

    if (_text.isNotEmpty) {
      setState(() {
        conversation.add({"question": _text, "response": ""});
      });
      _sendMessageToServer(_text);
      _text = "";
    }
  }

  void _handleTextSubmit() {
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      setState(() {
        conversation.add({"question": message, "response": ""});
      });
      _sendMessageToServer(message);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await ttsService.stop();
        return true;
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F5),
        appBar: AppBar(
          title: Semantics(
            header: true,
            label: '아티와 대화하기. 아래쪽의 입력창을 통해 챗봇 아티와 대화해보세요.',
            child: const Text(
              '아티와 대화하기',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          centerTitle: true,
          backgroundColor: const Color(0xFFF5F5F5),
          elevation: 0,
          leading: Semantics(
            label: '뒤로가기 버튼',
            button: true,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.black),
              onPressed: () {
                ttsService.stop();
                Navigator.pop(context);
              },
            ),
          ),
          actions: [
            Semantics(
              label: _isMuted ? '음소거 켜짐, 해제하려면 터치' : '음소거 꺼짐, 켜려면 터치',
              button: true,
              child: IconButton(
                icon: Icon(
                  _isMuted ? Icons.volume_off : Icons.volume_up,
                  color: Colors.black,
                ),
                onPressed: () {
                  setState(() {
                    _isMuted = !_isMuted;
                  });
                  // mute 상태에 따라 TTS의 볼륨을 조절합니다.
                  ttsService.setMute(_isMuted);
                },
              ),
            )
          ],
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 작품 이미지
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Semantics(
                label: '작품 이미지: ${widget.title}',
                image: true,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    widget.imageUrl,
                    width: double.infinity,
                    height: 200,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Center(child: CircularProgressIndicator()),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: double.infinity,
                        height: 200,
                        color: Colors.grey[300],
                        child: const Icon(Icons.error),
                      );
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            // 대화 목록
            Expanded(
              child: Stack(
                children: [
                  ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: conversation.length,
                    itemBuilder: (context, index) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (conversation[index]["question"]!.isNotEmpty)
                            Align(
                              alignment: Alignment.centerRight,
                              child: Semantics(
                                // label: '사용자 메시지: ${conversation[index]["question"]}',
                                label: '사용자 메시지',
                                child: _buildUserMessageBlock(conversation[index]["question"]!),
                              ),
                            ),
                          const SizedBox(height: 12),
                          if (conversation[index]["response"]!.isNotEmpty)
                            Align(
                              alignment: Alignment.centerLeft,
                              child: Semantics(
                                // label: '봇 응답: ${conversation[index]["response"]}',
                                label: '봇 응답',
                                child: _buildBotResponseBlock(conversation[index]["response"]!),
                              ),
                            ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),
                  if (_isLoading)
                    const Positioned(
                      left: 0,
                      right: 0,
                      bottom: 20,
                      child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
            ),
            // 입력 영역
            Semantics(
              container: true,
              label: '메시지 입력 영역',
              child: Container(
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
                      child: Semantics(
                        label: '메시지 입력 필드',
                        textField: true,
                        child: TextField(
                          controller: _textController,
                          decoration: InputDecoration(
                            hintText: '메시지를 입력하세요',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(24),
                              borderSide: BorderSide.none,
                            ),
                            filled: true,
                            fillColor: Colors.grey[200],
                            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          ),
                          style: const TextStyle(color: Colors.black87, fontSize: 16),
                          onSubmitted: (_) => _handleTextSubmit(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      label: _isListening ? '음성 인식 중지 버튼' : '음성 인식 시작 버튼',
                      button: true,
                      child: GestureDetector(
                        onTap: _isLoading ? null : (_isListening ? _stopVoiceRecognition : _startVoiceRecognition),
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
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      label: '메시지 보내기 버튼',
                      button: true,
                      child: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _isLoading ? null : _handleTextSubmit,
                        color: const Color(0xFF1E40AF),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUserMessageBlock(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(left: 40),
      decoration: BoxDecoration(
        color: const Color(0xFF1E40AF),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }

  Widget _buildBotResponseBlock(String text) {
    final hasLineBreak = text.contains('\n');

    return GestureDetector(
      onTap: () {
        // 음소거 상태가 아니라면 TTS로 읽어줍니다.
        if (!_isMuted) {
          ttsService.speak(text);
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        margin: const EdgeInsets.only(right: 40),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.black12),
        ),
        child: hasLineBreak
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: text.split('\n').map((line) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(line, style: const TextStyle(fontSize: 14, color: Colors.black87)),
            );
          }).toList(),
        )
            : Text(text, style: const TextStyle(fontSize: 14, color: Colors.black87)),
      ),
    );
  }

  @override
  void dispose() {
    _channel?.sink.close();
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}