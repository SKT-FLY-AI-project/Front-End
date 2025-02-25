import 'package:flutter/material.dart';
import 'analysis_record_screen.dart';
import 'conversation_detail_screen.dart';

class TabbedScreen extends StatefulWidget {
  final String imageUrl;
  final String title;
  final String artist;
  final String? vlmDescription;
  final String richDescription;
  final List<List<int>>? dominantColors;
  final String conversationId;

  const TabbedScreen({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.artist,
    this.vlmDescription,
    required this.richDescription,
    this.dominantColors,
    required this.conversationId,
  }) : super(key: key);

  @override
  _TabbedScreenState createState() => _TabbedScreenState();
}

class _TabbedScreenState extends State<TabbedScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF5F5F5),
        elevation: 0,
        bottom: TabBar(
          controller: _tabController,
          labelColor: Colors.black,
          unselectedLabelColor: Colors.black54,
          indicatorColor: const Color(0xFF1E40AF),
          tabs: const [
            Tab(text: "AI 분석"),
            Tab(text: "대화 기록"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          AnalysisRecordScreen(
            conversationId: widget.conversationId,
            imageUrl: widget.imageUrl,
            title: widget.title,
            artist: widget.artist,
            vlmDescription: widget.vlmDescription,
            richDescription: widget.richDescription,
            dominantColors: widget.dominantColors,
          ),
          ConversationDetailScreen(
            conversationId: widget.conversationId,
          ),
        ],
      ),
    );
  }
}
