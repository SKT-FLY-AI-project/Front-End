import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'login_screen.dart';
import 'diary_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: Colors.white,
        primaryColor: const Color(0xFF1E40AF),
        fontFamily: 'Pretendard', // 한글 폰트 적용 (앱에 폰트 추가 필요)
      ),
      home: const MyPageScreen(),
    );
  }
}

class MyPageScreen extends StatelessWidget {
  const MyPageScreen({super.key});

  Future<void> _showLogoutConfirmationDialog(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 아이콘
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: Colors.red[400],
                    size: 30,
                  ),
                ),
                const SizedBox(height: 20),
                // 제목
                const Text(
                  '로그아웃',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 12),
                // 내용
                const Text(
                  '로그아웃 하시겠습니까?',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
                const SizedBox(height: 28),
                // 버튼
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // 취소 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(false),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              '취소',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // 확인 버튼
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.of(context).pop(true),
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.red[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Center(
                            child: Text(
                              '로그아웃',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirm == true) {
      _handleLogout(context);
    }
  }

  Future<void> _handleLogout(BuildContext context) async {
    await secureStorage.delete(key: 'jwt_token');

    // 로그아웃 완료 후 스낵바로 메시지 표시
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('로그아웃 되었습니다.'),
        backgroundColor: Color(0xFF1E40AF),
        behavior: SnackBarBehavior.floating,
      ),
    );

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
    );
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final screenHeight = size.height;
    final screenWidth = size.width;

    return Scaffold(
      // backgroundColor: Colors.grey[50],
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: const BoxDecoration(
              color: Colors.transparent, // 흰색 대신 투명하게 변경
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87, size: 20),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          "마이페이지",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.transparent, // 투명하게 변경
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.settings_outlined, color: Colors.black87, size: 20),
            ),
            onPressed: () {
              // 설정 화면으로 이동
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            // 프로필 섹션 - 배경과 함께 표시
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                children: [
                  // 프로필 헤더
                  Container(
                    padding: const EdgeInsets.only(left: 24, right: 24, top: 30, bottom: 36),
                    width: double.infinity,
                    child: Column(
                      children: [
                        // 프로필 이미지
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: const Color(0xFF1E40AF),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              'assets/profile.jpg',
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        // 이름과 이메일
                        const Column(
                          children: [
                            Text(
                              "김민수",
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF1E3A8A),
                                letterSpacing: -0.5,
                              ),
                            ),
                            SizedBox(height: 4),
                            Text(
                              "rlaalstn21@naver.com",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // 활동 통계
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E40AF).withOpacity(0.05),
                      border: Border(
                        top: BorderSide(
                          color: const Color(0xFF1E40AF).withOpacity(0.1),
                          width: 1,
                        ),
                        bottom: BorderSide(
                          color: const Color(0xFF1E40AF).withOpacity(0.1),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        buildStatItem("337", "감상한 작품"),
                        Container(
                          height: 40,
                          width: 1,
                          color: Colors.grey.withOpacity(0.3),
                        ),
                        buildStatItem("337", "VTS 참여"),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // 설정 섹션
            Padding(
              padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.05),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 섹션 제목
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      "내 활동",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  // 메뉴 버튼들
                  buildMenuButton(
                    context,
                    title: "감상 일기",
                    subtitle: "내가 감상한 작품들의 기록을 확인해보세요",
                    icon: Icons.auto_stories_rounded,
                    iconBgColor: const Color(0xFF3B82F6).withOpacity(0.1),
                    iconColor: const Color(0xFF3B82F6),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const DiaryPage()),
                      );
                    },
                  ),

                  buildMenuButton(
                    context,
                    title: "학습 진도",
                    subtitle: "나의 미술 감상 학습 진도를 확인하세요",
                    icon: Icons.trending_up_rounded,
                    iconBgColor: const Color(0xFF4ADE80).withOpacity(0.1),
                    iconColor: const Color(0xFF4ADE80),
                  ),

                  const SizedBox(height: 24),

                  // 설정 섹션 제목
                  const Padding(
                    padding: EdgeInsets.only(left: 4, bottom: 16),
                    child: Text(
                      "설정",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),

                  // 설정 버튼들
                  buildMenuButton(
                    context,
                    title: "알림 설정",
                    subtitle: "알림 및 메시지 수신 설정을 관리하세요",
                    icon: Icons.notifications_outlined,
                    iconBgColor: const Color(0xFFFB7185).withOpacity(0.1),
                    iconColor: const Color(0xFFFB7185),
                  ),

                  buildMenuButton(
                    context,
                    title: "접근성 설정",
                    subtitle: "앱 사용 환경을 내게 맞게 조정하세요",
                    icon: Icons.accessibility_new_rounded,
                    iconBgColor: const Color(0xFFF59E0B).withOpacity(0.1),
                    iconColor: const Color(0xFFF59E0B),
                  ),

                  buildMenuButton(
                    context,
                    title: "계정 관리",
                    subtitle: "계정 정보를 관리하고 보안을 설정하세요",
                    icon: Icons.person_outline_rounded,
                    iconBgColor: const Color(0xFF6366F1).withOpacity(0.1),
                    iconColor: const Color(0xFF6366F1),
                  ),

                  buildMenuButton(
                    context,
                    title: "고객 지원",
                    subtitle: "도움이 필요하신가요? 문의하기",
                    icon: Icons.help_outline_rounded,
                    iconBgColor: const Color(0xFF64748B).withOpacity(0.1),
                    iconColor: const Color(0xFF64748B),
                    showDivider: false,
                  ),

                  // 로그아웃 버튼 (여기를 수정함!)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24),
                    child: GestureDetector(
                      onTap: () {
                        _showLogoutConfirmationDialog(context);
                      },
                      child: Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.logout_rounded,
                                color: Colors.red[400],
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                "로그아웃",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.red[400],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                  // 앱 버전
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.only(bottom: 40),
                      child: Text(
                        "앱 버전 1.2.3",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 통계 아이템 위젯
  Widget buildStatItem(String number, String label) {
    return Column(
      children: [
        Text(
          number,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1E40AF),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  // 메뉴 버튼 위젯
  Widget buildMenuButton(
      BuildContext context, {
        required String title,
        required String subtitle,
        required IconData icon,
        required Color iconBgColor,
        required Color iconColor,
        bool showDivider = true,
        VoidCallback? onTap,
      }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            color: Colors.transparent,
            child: Row(
              children: [
                // 아이콘
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: iconBgColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                // 텍스트
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                // 화살표
                Icon(
                  Icons.chevron_right_rounded,
                  color: Colors.grey[400],
                  size: 24,
                ),
              ],
            ),
          ),
          // 구분선
          showDivider
              ? Divider(
            color: Colors.grey[200],
            thickness: 1,
            height: 1,
          )
              : const SizedBox(),
        ],
      ),
    );
  }
}