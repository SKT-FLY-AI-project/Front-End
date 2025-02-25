// mock_artwork_service 실제 서버 응답을 시뮬레이션 하기 위한 작업
import 'artwork_model.dart';
import 'conversation_model.dart';

class MockArtworkService {
  static final List<ArtworkModel> _mockArtworks = [
    ArtworkModel(
      id: 1,
      title: '별이 빛나는 밤',
      artist: '빈센트 반 고흐',
      year: '1889',
      imagePath: 'assets/pictop.png',
      aiAnalysis: '이 작품은 후기 인상주의의 대표작으로, 소용돌이치는 별들과 함께 하늘과 땅이 역동적으로 표현되어 있습니다. 강렬한 감정 표현과 대담한 붓질로 작가의 내면 세계를 표현하고 있습니다.',
      date: DateTime(2025, 2, 19),
    ),
    ArtworkModel(
      id: 2,
      title: '사이프러스가 있는 밀밭',
      artist: '빈센트 반 고흐',
      year: '1889',
      imagePath: 'assets/picbot.png',
      aiAnalysis: '황금빛 밀밭과 어두운 사이프러스 나무의 대비가 인상적인 작품입니다. 자연의 생명력과 역동성이 고흐 특유의 붓터치로 표현되어 있습니다.',
      date: DateTime(2025, 2, 19),
    ),
  ];

  // 모든 작품 가져오기 메서드 추가
  Future<List<ArtworkModel>> getAllArtworks() async {
    await Future.delayed(const Duration(milliseconds: 500));
    return List.from(_mockArtworks); // 원본 리스트의 복사본 반환
  }

  Future<List<ArtworkModel>> getArtworksByDate(DateTime date) async {
    await Future.delayed(const Duration(milliseconds: 500));
    return _mockArtworks.where((artwork) =>
    artwork.date.year == date.year &&
        artwork.date.month == date.month &&
        artwork.date.day == date.day
    ).toList();
  }

  Future<ArtworkModel?> findArtworkByTitle(String title) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockArtworks.firstWhere((artwork) => artwork.title == title);
    } catch (e) {
      return null;
    }
  }

  Future<ArtworkModel?> getArtworkById(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _mockArtworks.firstWhere((artwork) => artwork.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<void> deleteArtwork(int id) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _mockArtworks.removeWhere((artwork) => artwork.id == id);
  }

  // 이미지 경로로 작품 찾기
  Future<ArtworkModel?> getArtworkByImagePath(String imagePath) async {
    // 모든 작품 불러오기
    final allArtworks = await getAllArtworks();

    // 이미지 경로가 일치하는 작품 찾기
    try {
      return allArtworks.firstWhere((artwork) => artwork.imagePath == imagePath);
    } catch (e) {
      return null; // 일치하는 작품이 없는 경우
    }
  }

  // 작품 ID로 대화 기록 불러오기
  Future<List<ConversationModel>> getConversationsByArtworkId(int artworkId) async {
    // 실제 앱에서는 데이터베이스나 API에서 데이터를 불러오겠지만,
    // 여기서는 모의 데이터를 반환합니다.
    await Future.delayed(const Duration(milliseconds: 500)); // 실제 데이터 로딩 시뮬레이션

    // 샘플 대화 데이터
    if (artworkId == 1) { // 별이 빛나는 밤 (예시)
      return [
        ConversationModel(
          id: 1,
          artworkId: artworkId,
          message: "이 작품에서 무엇이 보여?",
          isUserMessage: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        ConversationModel(
          id: 2,
          artworkId: artworkId,
          message: "별빛과 소용돌이치는 하늘이 가장 인상적인 걸 보여요. 마치 살아 움직이는 것같은 느낌입니다.",
          isUserMessage: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 29)),
        ),
        ConversationModel(
          id: 3,
          artworkId: artworkId,
          message: "고흐라는 사람은 어떤 인생을 살았어?",
          isUserMessage: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 20)),
        ),
        ConversationModel(
          id: 4,
          artworkId: artworkId,
          message: "고흐는 평생 정신적 고통과 경제적 어려움 속에서 살았지만, 단 10년이라는 짧은 예술 활동 기간 동안 2,000여 점의 작품을 남겼습니다. "
              "그는 생전에 단 한 점의 작품만 팔았고, 37세에 스스로 목숨을 끊었지만, 사후에 현대 미술에 가장 큰 영향을 미친 화가 중 한 명으로 평가받습니다.",
          isUserMessage: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 19)),
        ),
        ConversationModel(
          id: 5,
          artworkId: artworkId,
          message: "고흐라는 사람이 죽고 난 후 주목을 받은 이유는 뭐야?",
          isUserMessage: true,
          timestamp: DateTime.now().subtract(const Duration(minutes: 30)),
        ),
        ConversationModel(
          id: 6,
          artworkId: artworkId,
          message: "고흐가 사후에 주목받은 이유는 그의 독창적인 표현 방식과 강렬한 감정을 담은 작품들 때문입니다. 그의 동생 테오의 아내가 고흐의 작품을 적극적으로 홍보했고, 평론가들이 그의 혁신적인 색채 사용과 붓 터치를 인정하게 되었습니다. 특히 인상주의 이후 예술의 방향을 제시한 표현주의의 선구자로 평가받으며, 현대 미술에 지대한 영향을 미쳤습니다.",
          isUserMessage: false,
          timestamp: DateTime.now().subtract(const Duration(minutes: 29)),
        ),
      ];
    } else if (artworkId == 2) { // 다른 작품
      return [
        ConversationModel(
          id: 5,
          artworkId: artworkId,
          message: "이 작품의 주제는 무엇인가요?",
          isUserMessage: true,
          timestamp: DateTime.now().subtract(const Duration(hours: 2)),
        ),
        ConversationModel(
          id: 6,
          artworkId: artworkId,
          message: "이 작품은 자연과 인간의 조화를 표현하고 있습니다.",
          isUserMessage: false,
          timestamp: DateTime.now().subtract(const Duration(hours: 1, minutes: 58)),
        ),
      ];
    }

    // 해당 작품의 대화 기록이 없는 경우
    return [];
  }
}