import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:camera/camera.dart';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart';
import 'dart:io';
import 'dart:async';
import 'dart:convert';
import 'analysis_screen.dart';
import '../config/app_config.dart';
import '../services/auth_service.dart';
import '../services/tts_service.dart';

class CameraScreen extends StatefulWidget {
  final CameraDescription camera;

  const CameraScreen({Key? key, required this.camera}) : super(key: key);

  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> with WidgetsBindingObserver {
  static final AppConfig _config = AppConfig();

  late CameraController _controller;
  double _currentZoom = 1.0;
  double _minZoom = 1.0;
  double _maxZoom = 8.0;
  final Dio _dio = Dio(BaseOptions(
    followRedirects: true,
  ));

  // 화면에 출력되는 로딩 메시지 (TTS와 분리됨)
  String _currentStatus = "대기 중...";

  // 로딩 다이얼로그 표시 여부
  bool _isProcessing = false;

  // 분석 완료 여부 (분석 완료 TTS 중복 방지)
  bool _analysisCompleted = false;

  // 객체 탐지 정보
  Map<String, dynamic>? _detectionData;
  bool _objectDetected = false;
  bool _objectCentered = false;

  // TTS 및 배경음악 관련 변수
  late FlutterTts flutterTts;
  late AudioPlayer audioPlayer;
  Timer? friendlyMessageTimer; // 주기적인 TTS 안내 메시지 타이머
  Timer? detectionTimer; // 주기적인 객체 탐지 타이머

  // 음소거 여부 상태 변수
  bool _isMuted = false;

  // 화면 활성 상태 관리
  bool _isActiveScreen = true;

  // TTS로 출력할 친절한 안내 메시지 목록 (서버 업데이트와 별도)
  final List<String> friendlyMessages = [
    "AI가 그림을 분석하는 중입니다.",
    "설명을 생성하는 중입니다.",
    "잠시만 기다려주세요."
  ];
  int friendlyMessageIndex = 0;

  final TTSService ttsService = TTSService();

  @override
  void initState() {
    super.initState();
    // WidgetsBinding 옵저버 등록 (앱 생명주기 감지)
    WidgetsBinding.instance.addObserver(this);

    // TTS 및 AudioPlayer 초기화
    flutterTts = FlutterTts();
    audioPlayer = AudioPlayer();
    // 배경음악은 루프 모드 설정
    audioPlayer.setReleaseMode(ReleaseMode.loop);

    _controller =
        CameraController(widget.camera, ResolutionPreset.medium, enableAudio: false);
    _controller.initialize().then((_) async {
      if (!mounted) return;
      await _controller.setFlashMode(FlashMode.off);
      _minZoom = await _controller.getMinZoomLevel();
      _maxZoom = await _controller.getMaxZoomLevel();
      setState(() {});

      // 카메라 초기화 후 객체 탐지 타이머 시작
      _startObjectDetection();
    }).catchError((e) {
      print("카메라 초기화 오류: $e");
    });
  }

  @override
  void dispose() {
    // 옵저버 제거
    WidgetsBinding.instance.removeObserver(this);
    _cleanupResources();
    super.dispose();
  }

  // 앱 생명주기 변경 시 호출되는 메서드
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    // 앱이 백그라운드로 갔을 때 자원 정리
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive ||
        state == AppLifecycleState.detached) {
      _stopAllAudioAndTTS();
    }
  }

  // 모든 자원 정리
  void _cleanupResources() {
    _controller.dispose();
    audioPlayer.dispose();
    _stopAllAudioAndTTS();
    friendlyMessageTimer?.cancel();
    detectionTimer?.cancel();
  }

  // 모든 오디오 및 TTS 중지
  void _stopAllAudioAndTTS() {
    audioPlayer.stop();
    flutterTts.stop();
    ttsService.stop();
    friendlyMessageTimer?.cancel();
  }

  void _zoomCamera(double zoom) async {
    setState(() {
      _currentZoom = zoom.clamp(_minZoom, _maxZoom);
    });
    _controller.setZoomLevel(_currentZoom);
  }

  // 정기적인 객체 탐지 시작
  void _startObjectDetection() {
    detectionTimer = Timer.periodic(const Duration(milliseconds: 4000), (timer) async {
      if (!_isProcessing && _controller.value.isInitialized && _isActiveScreen) {
        await _detectObjectInFrame();
      }
    });
  }

  // 현재 카메라 프레임에서 객체 탐지
  Future<void> _detectObjectInFrame() async {
    if (!mounted || _isProcessing || !_isActiveScreen) return;

    try {
      final XFile image = await _controller.takePicture();
      await _sendImageForDetection(File(image.path));
    } catch (e) {
      print("객체 탐지 중 오류 발생: $e");
    }
  }

  // 객체 탐지를 위한 이미지 전송
  Future<void> _sendImageForDetection(File imageFile) async {
    if (!mounted || !_isActiveScreen) return;

    try {
      String fileName = imageFile.path.split('/').last;
      String? mimeType = lookupMimeType(imageFile.path) ?? "image/jpeg";

      FormData detectFormData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      // 객체 탐지 엔드포인트로 요청 (단일 객체만 탐지하도록 파라미터 추가)
      var response = await _dio.post(
        "${_config.apiUrl}/camera/detect/", // 객체 탐지 엔드포인트
        data: detectFormData,
        queryParameters: {"max_objects": 1}, // 단일 객체만 탐지
      );

      if (response.statusCode == 200 && mounted && _isActiveScreen) {
        Map<String, dynamic> data = response.data;
        setState(() {
          _detectionData = data;
          _objectDetected = data['detected'] ?? false;
          _objectCentered = data['centered'] ?? false;
        });

        // 객체가 탐지되었고, 음소거가 아니며, 처리 중이 아닐 때 음성 안내
        if (_objectDetected && !_isMuted && !_isProcessing && _isActiveScreen) {
          if (_objectCentered) {
            await flutterTts.speak("객체가 중앙에 위치했습니다.");
          } else if (data.containsKey('direction')) {
            await flutterTts.speak(data['direction']);
          }
        }
      }
    } catch (e) {
      print("객체 탐지 API 요청 오류: $e");
    }
  }

  // 촬영 버튼을 누르면 카메라 프리뷰를 일시 정지하고, 로딩 다이얼로그(오버레이)와 함께 프로세스 시작
  Future<void> _uploadAndProcessImage(String imagePath) async {
    try {
      // 초기 상태 설정 및 카메라 정지
      setState(() {
        _currentStatus = "대기 중...";
        _isProcessing = true;
        _analysisCompleted = false;
      });
      await _controller.pausePreview();
      _startProcessing();

      File imageFile = File(imagePath);
      String fileName = imageFile.path.split('/').last;
      String? mimeType = lookupMimeType(imageFile.path) ?? "image/jpeg";

      FormData detectFormData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          imageFile.path,
          filename: fileName,
          contentType: MediaType.parse(mimeType),
        ),
      });

      String? userId = await AuthService.getUserId();
      var response = await _dio.post(
        "${_config.apiUrl}/describe/$userId/",
        data: detectFormData,
        options: Options(responseType: ResponseType.stream),
      );

      Stream<List<int>> responseStream = response.data.stream;
      StringBuffer completeResponse = StringBuffer();

      responseStream
          .cast<List<int>>()
          .transform(utf8.decoder)
          .transform(const LineSplitter())
          .listen((line) async {
        print("수신된 SSE 데이터: $line");

        if (line.startsWith("data: ")) {
          line = line.substring(6);
        }

        try {
          final jsonData = json.decode(line);
          completeResponse.write(line);

          if (jsonData.containsKey("status") && mounted && _isActiveScreen) {
            // 화면에 로딩 메시지 업데이트 (TTS와 분리)
            setState(() {
              _currentStatus = jsonData["status"];
            });
          }

          if (jsonData.containsKey("completed") && jsonData["completed"] == true) {
            if (!_analysisCompleted && mounted && _isActiveScreen) {
              _analysisCompleted = true;
              if (!_isMuted) {
                await flutterTts.speak("분석이 완료되었습니다.");
              }
            }
            _stopProcessing();
            if (jsonData.containsKey("error") && jsonData["error"] == true && mounted && _isActiveScreen) {
              _showErrorDialog(jsonData["status"]);
              return;
            }
          }
        } catch (e) {
          print("JSON 파싱 오류: $e");
        }
      }, onError: (error) {
        _stopProcessing();
        if (mounted && _isActiveScreen) {
          _showErrorDialog('이미지 처리 중 오류가 발생했습니다.\n$error');
        }
      }, onDone: () {
        _stopProcessing();
        try {
          if (!mounted || !_isActiveScreen) return;

          List<String> jsonObjects = completeResponse.toString().split("}{");

          for (int i = 0; i < jsonObjects.length; i++) {
            if (i != 0) jsonObjects[i] = "{${jsonObjects[i]}";
            if (i != jsonObjects.length - 1) jsonObjects[i] = "${jsonObjects[i]}}";
          }

          Map<String, dynamic>? finalJson;
          for (var jsonString in jsonObjects) {
            try {
              var parsedJson = json.decode(utf8.decode(jsonString.codeUnits));
              if (parsedJson.containsKey("completed") && parsedJson["completed"] == true) {
                finalJson = parsedJson;
                break;
              }
            } catch (e) {
              print("JSON 파싱 오류: $e, 원본 데이터: $jsonString");
            }
          }

          if (finalJson != null && finalJson.containsKey("data")) {
            var jsonData = finalJson["data"];

            // 화면 전환 전에 모든 음성 출력 중지
            _stopAllAudioAndTTS();

            // 화면 활성 상태 비활성화
            setState(() {
              _isActiveScreen = false;
            });

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AnalysisScreen(
                  imageUrl: jsonData['image_url'] ?? "",
                  title: jsonData['title'],
                  artist: jsonData['artist'],
                  // title: "여름의 베퇴유",
                  // artist: "모네",
                  vlmDescription: jsonData['vlm_description'] ?? "설명 없음",
                  richDescription: jsonData['rich_description'] ?? "설명 없음",
                  dominantColors: (jsonData['dominant_colors'] as List)
                      .map((colorList) => List<int>.from(colorList))
                      .toList(),
                  audioUrl: jsonData.containsKey('audio_url') ? jsonData['audio_url'] : "",
                ),
              ),
            ).then((_) {
              // 분석 화면에서 돌아왔을 때 다시 카메라 화면 활성화
              if (mounted) {
                setState(() {
                  _isActiveScreen = true;
                });
                // 다시 객체 탐지 시작
                _startObjectDetection();
              }
            });
          } else {
            throw Exception("완전한 JSON 응답을 찾을 수 없음.");
          }
        } catch (e) {
          print("최종 JSON 파싱 오류: $e");
          if (mounted && _isActiveScreen) {
            _showErrorDialog("JSON 응답 처리 중 오류 발생\n$e");
          }
        }
      });
    } catch (e) {
      _stopProcessing();
      if (mounted && _isActiveScreen) {
        _showErrorDialog('이미지 처리 중 오류가 발생했습니다.\n${e.toString()}');
      }
    }
  }

  // 로딩 프로세스 시작: 배경음악 재생(음소거 시 재생하지 않음) 및 TTS 안내 타이머 시작
  void _startProcessing() async {
    if (!_isMuted && _isActiveScreen) {
      audioPlayer.play(AssetSource('loading_music.mp3'), volume: 0.5);
      // 촬영 직후 첫 안내 메시지 출력
      await flutterTts.speak(friendlyMessages[0]);
    }
    friendlyMessageIndex = 1;
    friendlyMessageTimer = Timer.periodic(const Duration(seconds: 10), (timer) async {
      if (!_isMuted && mounted && _isActiveScreen) {
        await flutterTts.speak(friendlyMessages[friendlyMessageIndex]);
      }
      friendlyMessageIndex = (friendlyMessageIndex + 1) % friendlyMessages.length;
    });
  }

  // 로딩 프로세스 종료: 배경음악 정지, TTS 타이머 취소, 카메라 프리뷰 재개, 다이얼로그 숨김
  void _stopProcessing() {
    audioPlayer.stop();
    friendlyMessageTimer?.cancel();
    if (_controller.value.isInitialized) {
      _controller.resumePreview();
    }
    if (mounted) {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('오류'),
          content: Text(message),
          actions: [
            TextButton(
              child: const Text('확인'),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        _stopAllAudioAndTTS();
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              _stopAllAudioAndTTS();
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            "카메라",
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.black,
          actions: [
            IconButton(
              icon: Icon(
                _isMuted ? Icons.volume_off : Icons.volume_up,
                color: Colors.white,
              ),
              onPressed: () {
                setState(() {
                  _isMuted = !_isMuted;
                });
                if (_isMuted) {
                  // 음소거 시 재생 중인 음악 정지
                  audioPlayer.stop();
                  flutterTts.stop();
                } else {
                  // 음소거 해제 시, 처리 중이면 음악 재생
                  if (_isProcessing) {
                    audioPlayer.play(AssetSource('loading_music.mp3'), volume: 0.5);
                  }
                }
              },
            ),
          ],
        ),
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            Column(
              children: [
                Expanded(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      CameraPreview(_controller),
                      // 촬영 버튼 누른 동안 카메라 프리뷰를 어둡게 처리
                      if (_isProcessing)
                        Container(
                          color: Colors.black.withOpacity(0.3),
                        ),
                      // 중앙 가이드 박스
                      Image.asset(
                        'assets/guide_box.png',
                        width: 300,
                        height: 500,
                        fit: BoxFit.contain,
                      ),
                    ],
                  ),
                ),
                // 객체 위치 안내 텍스트
                if (_objectDetected && _detectionData != null && !_isProcessing)
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
                    color: Colors.black.withOpacity(0.7),
                    child: Text(
                      _objectCentered
                          ? "객체가 중앙에 위치했습니다."
                          : (_detectionData!.containsKey('direction')
                          ? _detectionData!['direction']
                          : "객체를 중앙으로 이동하세요"),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  child: Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, color: Colors.white),
                        onPressed: () => _zoomCamera(_currentZoom - 0.1),
                      ),
                      Expanded(
                        child: Slider(
                          activeColor: Colors.white,
                          min: _minZoom,
                          max: _maxZoom,
                          value: _currentZoom,
                          onChanged: _isProcessing ? null : (value) => _zoomCamera(value),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add, color: Colors.white),
                        onPressed: () => _zoomCamera(_currentZoom + 0.1),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GestureDetector(
                    onTap: _objectCentered && !_isProcessing
                        ? () async {
                      try {
                        final image = await _controller.takePicture();
                        if (!mounted) return;
                        _uploadAndProcessImage(image.path);
                      } catch (e) {
                        print("Error taking picture: $e");
                      }
                    }
                        : null,
                    child: Container(
                      width: 70,
                      height: 70,
                      decoration: BoxDecoration(
                        color: _objectCentered && !_isProcessing ? Colors.white : Colors.grey,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // 로딩 다이얼로그(오버레이): _isProcessing true일 때 중앙에 표시
            if (_isProcessing)
              Positioned.fill(
                child: IgnorePointer(
                  ignoring: false,
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    child: Center(
                      child: Dialog(
                        backgroundColor: Colors.black.withOpacity(0.7),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                _currentStatus,
                                style: const TextStyle(color: Colors.white, fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}