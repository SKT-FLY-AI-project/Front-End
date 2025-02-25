// import 'package:flutter/material.dart';
// import 'package:camera/camera.dart';
// import 'services/permission_service.dart';
// import 'services/auth_service.dart';
// import 'screens/loading_screen.dart';
// import 'screens/home_screen.dart';
// import 'screens/login_screen.dart';
//
// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   runApp(MyApp());
// }
//
// class MyApp extends StatelessWidget {
//   const MyApp({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'ArtChemy',
//       home: FutureBuilder<String?>(
//         future: AuthService.getToken(), // 로그인 토큰을 비동기적으로 가져옴
//         builder: (context, snapshot) {
//           // 로딩 중에는 간단한 로딩 위젯을 표시
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Scaffold(
//               body: Center(child: CircularProgressIndicator()),
//             );
//           }
//           // 토큰이 존재하면 홈 화면으로, 없으면 로그인 화면으로 이동
//           if (snapshot.hasData && snapshot.data != null && snapshot.data!.isNotEmpty) {
//             return const HomeScreen();
//           } else {
//             return const LoginScreen();
//           }
//         },
//       ),
//     );
//   }
// }
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final cameras = await availableCameras();
  runApp(MyApp(cameras: cameras));
}

class MyApp extends StatelessWidget {
  final List<CameraDescription> cameras;

  const MyApp({Key? key, required this.cameras}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: CameraGuide(cameras: cameras),
    );
  }
}

class CameraGuide extends StatefulWidget {
  final List<CameraDescription> cameras;

  const CameraGuide({Key? key, required this.cameras}) : super(key: key);

  @override
  _CameraGuideState createState() => _CameraGuideState();
}

class _CameraGuideState extends State<CameraGuide> {
  late CameraController _controller;
  bool isInFrame = false;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.cameras[0],
      ResolutionPreset.high,
    );
    _controller.initialize().then((_) {
      if (!mounted) return;
      setState(() {});
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      body: Stack(
        children: [
          CameraPreview(_controller),
          // 가이드 오버레이
          Center(
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                border: Border.all(
                  color: isInFrame ? Colors.green : Colors.red,
                  width: 3,
                ),
              ),
            ),
          ),
          // 안내 텍스트
          Positioned(
            bottom: 50,
            left: 0,
            right: 0,
            child: Text(
              isInFrame ? '프레임 안에 잘 들어왔습니다!' : '피사체를 프레임 안으로 맞춰주세요',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: isInFrame ? Colors.green : Colors.red,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                backgroundColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.camera),
        onPressed: () {
          // 사진 촬영 로직
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}