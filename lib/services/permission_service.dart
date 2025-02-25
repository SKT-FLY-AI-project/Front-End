import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermission() async {
  if (await Permission.storage.request().isGranted) {
    print("✅ 파일 접근 권한 허용됨");
  } else {
    print("❌ 파일 접근 권한 거부됨. 설정에서 허용해주세요.");
  }
}
