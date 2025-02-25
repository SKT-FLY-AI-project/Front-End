import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vts_screen.dart'; // Import your VtsScreen
import '../config/app_config.dart';
import '../services/auth_service.dart';

class ConversationDetailScreen extends StatefulWidget {
  final String conversationId;

  const ConversationDetailScreen({
    Key? key,
    required this.conversationId,
  }) : super(key: key);

  @override
  _ConversationDetailScreenState createState() => _ConversationDetailScreenState();
}

class _ConversationDetailScreenState extends State<ConversationDetailScreen> {
  static final AppConfig _config = AppConfig();

  bool isLoading = true;
  String? errorMessage;
  Map<String, dynamic>? conversationData;
  List<Map<String, dynamic>> messages = [];
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _fetchConversationDetail();
  }

  Future<void> _fetchConversationDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    String? userId = await AuthService.getUserId();

    try {
      final response = await http.get(
        Uri.parse('${_config.apiUrl}/chat/${widget.conversationId}/detail?userid=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          conversationData = data;
          // Convert each message to Map<String, dynamic>
          messages = List<Map<String, dynamic>>.from(
            data['messages'].map((msg) => {
              'role': msg['role'],
              'content': msg['content'],
            }),
          );
          isLoading = false;
        });

        // Scroll to bottom after loading messages
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });
      } else {
        setState(() {
          errorMessage = '대화 내용을 불러오는데 실패했습니다: ${response.statusCode}';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = '서버 연결 오류: $e';
        isLoading = false;
      });
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

  void _continueConversation() {
    if (conversationData == null) return;

    // Convert messages to List<Map<String, String>> for VtsScreen
    final List<Map<String, String>> vtsMessages = messages.map((msg) => {
      'role': msg['role'] as String,
      'content': msg['content'] as String,
    }).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VtsScreen(
          imageUrl: conversationData!['image_url'],
          title: conversationData!['title'],
          artist: conversationData!['artist'],
          richDescription: conversationData!['rich_description'] ?? "",
          dominantColors: [], // You might need to add this from your data
          conversationId: widget.conversationId,
          initialMessages: vtsMessages,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      // appBar: AppBar(
      //   title: Text(
      //     conversationData != null
      //         ? conversationData!['title']
      //         : '대화 내용',
      //     style: const TextStyle(fontSize: 20.0, fontWeight: FontWeight.bold, color: Colors.black),
      //   ),
      //   centerTitle: true,
      //   backgroundColor: const Color(0xFFF5F5F5),
      //   elevation: 0,
      //   leading: IconButton(
      //     icon: const Icon(Icons.arrow_back, color: Colors.black),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   actions: [
      //     IconButton(
      //       icon: const Icon(Icons.refresh, color: Colors.black),
      //       onPressed: _fetchConversationDetail,
      //     ),
      //   ],
      // ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
          : Column(
        children: [
          if (conversationData != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  conversationData!['image_url'],
                  width: double.infinity,
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (ctx, error, stackTrace) {
                    return Container(
                      width: double.infinity,
                      height: 180,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported),
                    );
                  },
                ),
              ),
            ),
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('대화 내용이 없습니다.'))
                : ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                final isUser = message['role'] == 'user';

                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Align(
                    alignment: isUser
                        ? Alignment.centerRight
                        : Alignment.centerLeft,
                    child: Container(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width * 0.7,
                      ),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isUser
                            ? const Color(0xFF1E40AF)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: isUser
                            ? null
                            : Border.all(color: Colors.black12),
                      ),
                      child: Text(
                        message['content'] ?? '',
                        style: TextStyle(
                          fontSize: isUser ? 16 : 14,
                          color: isUser ? Colors.white : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: (!isLoading && errorMessage == null && conversationData != null)
          ? FloatingActionButton.extended(
        onPressed: _continueConversation,
        icon: const Icon(Icons.chat, color: Colors.white),
        label: const Text('대화 계속하기', style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF1E40AF),
      )
          : null,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }
}