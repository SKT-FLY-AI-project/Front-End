import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'vts_screen.dart'; // Import your VtsScreen
import '../config/app_config.dart';
import '../services/auth_service.dart';

class ConversationHistoryScreen extends StatefulWidget {
  const ConversationHistoryScreen({Key? key}) : super(key: key);

  @override
  _ConversationHistoryScreenState createState() => _ConversationHistoryScreenState();
}

class _ConversationHistoryScreenState extends State<ConversationHistoryScreen> {
  static final AppConfig _config = AppConfig();

  List<Map<String, dynamic>> conversations = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchConversations();
  }

  Future<void> _fetchConversations() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    String? userId = await AuthService.getUserId();

    try {
      final response = await http.get(
        Uri.parse('${_config.apiUrl}/chat/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));
        setState(() {
          conversations = List<Map<String, dynamic>>.from(data['conversations']);
          isLoading = false;
        });
      } else {
        setState(() {
          errorMessage = '대화 목록을 불러오는데 실패했습니다: ${response.statusCode}';
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

  void _openConversation(String conversationId, String imageUrl, String title) async {
    setState(() {
      isLoading = true;
    });
    String? userId = await AuthService.getUserId();

    try {
      final response = await http.get(
        Uri.parse('${_config.apiUrl}/chat/$conversationId/detail?userid=$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(utf8.decode(response.bodyBytes));;
        final List<Map<String, String>> messages = List<Map<String, String>>.from(
          data['messages'].map((msg) => {
            'role': msg['role'],
            'content': msg['content'],
          }),
        );

        if (!mounted) return;

        // Navigate to VtsScreen with conversation history
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VtsScreen(
              imageUrl: imageUrl,
              title: title,
              artist: data['artist'], // You might want to adjust this
              richDescription: data['rich_description'] ?? "",
              dominantColors: [], // You might need to add this from your data
              conversationId: conversationId,
              initialMessages: messages,
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('대화 내용을 불러오는데 실패했습니다: ${response.statusCode}')),
        );
      }

      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('서버 연결 오류: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text(
          '내 대화 기록',
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
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black),
            onPressed: _fetchConversations,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(child: Text(errorMessage!, style: const TextStyle(color: Colors.red)))
          : conversations.isEmpty
          ? const Center(child: Text('대화 기록이 없습니다.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: conversations.length,
        itemBuilder: (context, index) {
          final conversation = conversations[index];
          final lastMessageDate = DateTime.parse(conversation['updated_at']);
          final formattedDate = '${lastMessageDate.year}/${lastMessageDate.month}/${lastMessageDate.day} ${lastMessageDate.hour}:${lastMessageDate.minute.toString().padLeft(2, '0')}';

          return GestureDetector(
            onTap: () => _openConversation(
              conversation['conversation_id'],
              conversation['image_url'],
              conversation['title'],
            ),
            child: Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(12),
                      topRight: Radius.circular(12),
                    ),
                    child: Image.network(
                      conversation['image_url'],
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, error, stackTrace) {
                        return Container(
                          width: double.infinity,
                          height: 150,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          conversation['title'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '마지막 메시지: ${conversation['last_message'] ?? ''}',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black54,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.black45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}