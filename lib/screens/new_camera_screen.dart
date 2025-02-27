import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  CameraController? _controller;
  late List<CameraDescription> cameras;
  bool isDetecting = false;
  String guidanceMessage = "사물을 가이드라인 안에 맞춰 주세요";

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    cameras = await availableCameras();
    _controller = CameraController(cameras[0], ResolutionPreset.medium);
    await _controller!.initialize();
    if (mounted) {
      setState(() {});
    }
    _startDetectionLoop();
  }

  void _startDetectionLoop() {
    Timer.periodic(Duration(seconds: 2), (timer) async {
      if (!isDetecting && _controller != null && _controller!.value.isInitialized) {
        isDetecting = true;
        await _captureAndSendFrame();
        isDetecting = false;
      }
    });
  }

  Future<void> _captureAndSendFrame() async {
    try {
      final XFile file = await _controller!.takePicture();
      final File imageFile = File(file.path);
      final String message = await _sendImageToServer(imageFile);
      setState(() {
        guidanceMessage = message;
      });
    } catch (e) {
      print("Error capturing frame: $e");
    }
  }

  Future<String> _sendImageToServer(File imageFile) async {
    final uri = Uri.parse("http://your-fastapi-server.com/detect");
    var request = http.MultipartRequest('POST', uri)
      ..files.add(await http.MultipartFile.fromPath('file', imageFile.path));

    final response = await request.send();
    if (response.statusCode == 200) {
      final responseString = await response.stream.bytesToString();
      return responseString;
    }
    return "오류 발생. 다시 시도하세요.";
  }

  @override
  Widget build(BuildContext context) {
    if (_controller == null || !_controller!.value.isInitialized) {
      return Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(title: Text("사물 인식 카메라")),
      body: Stack(
        children: [
          CameraPreview(_controller!),
          Center(
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.red, width: 3),
              ),
            ),
          ),
          Positioned(
            bottom: 50,
            left: 20,
            right: 20,
            child: Text(
              guidanceMessage,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, color: Colors.white, backgroundColor: Colors.black54),
            ),
          ),
        ],
      ),
    );
  }
}
