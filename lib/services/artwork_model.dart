//artwork_model 테스트 데이터 용 모델
class ArtworkModel {
  final int id;
  final String title;
  final String artist;
  final String year;
  final String imagePath;
  final String aiAnalysis;
  final DateTime date;

  ArtworkModel({
    required this.id,
    required this.title,
    this.artist = '',
    this.year = '',
    required this.imagePath,
    this.aiAnalysis = '',
    required this.date,
  });
}