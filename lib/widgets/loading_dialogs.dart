import 'dart:async';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';

class LoadingDialog extends StatefulWidget {
  const LoadingDialog({Key? key}) : super(key: key);

  @override
  _LoadingDialogState createState() => _LoadingDialogState();
}

class _LoadingDialogState extends State<LoadingDialog> {
  static final AppConfig _config = AppConfig();

  String loadingMessage = "요청을 준비 중...";
  bool processing = true;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _startPolling());  // ✅ 다이얼로그 열린 후 타이머 실행
  }

  void _startPolling() async {
    String? userId = await AuthService.getUserId();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) async {
      if (!processing) {
        timer.cancel();
        return;
      }
      try {
        var response = await Dio().get("${_config.apiUrl}/chat/status/${userId}");
        String newStatus = response.data["status"];
        if (mounted) {
          setState(() => loadingMessage = newStatus);
        }
        if (newStatus == "완료") {
          processing = false;
          if (mounted) {
            Navigator.pop(context);  // ✅ 다이얼로그 자동 닫기
          }
          timer.cancel();
        }
      } catch (e) {
        print("상태 업데이트 오류: $e");
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: Colors.black87,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            loadingMessage,
            style: const TextStyle(color: Colors.white),
          ),
        ],
      ),
    );
  }
}
