// diary_service.dart
import 'artwork_model.dart';
import 'mock_artwork_service.dart';

class DiaryService {
  final MockArtworkService _mockArtworkService = MockArtworkService();

  Future<List<ArtworkModel>> getArtworksByDate(DateTime date) async {
    final mockArtworks = await _mockArtworkService.getArtworksByDate(date);
    return mockArtworks.map((artwork) => ArtworkModel(
      id: artwork.id,
      title: artwork.title,
      imagePath: artwork.imagePath,
      date: artwork.date,
    )).toList();
  }

  Future<ArtworkModel?> findArtworkByTitle(String title) async {
    final mockArtwork = await _mockArtworkService.findArtworkByTitle(title);
    if (mockArtwork == null) return null;
    return ArtworkModel(
      id: mockArtwork.id,
      title: mockArtwork.title,
      imagePath: mockArtwork.imagePath,
      date: mockArtwork.date,
    );
  }

  Future<ArtworkModel?> getArtworkById(int id) async {
    final mockArtwork = await _mockArtworkService.getArtworkById(id);
    if (mockArtwork == null) return null;
    return ArtworkModel(
      id: mockArtwork.id,
      title: mockArtwork.title,
      imagePath: mockArtwork.imagePath,
      date: mockArtwork.date,
    );
  }

  Future<void> deleteArtwork(int id) async {
    await _mockArtworkService.deleteArtwork(id);
  }
}