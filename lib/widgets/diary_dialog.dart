// diary_dialog.dart
import 'package:flutter/material.dart';

class DiaryDialogs {
  static void showArtworkNotFoundDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('작품을 찾을 수 없습니다'),
        content: const Text('입력하신 제목의 작품을 찾을 수 없습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('확인'),
          ),
        ],
      ),
    );
  }
}