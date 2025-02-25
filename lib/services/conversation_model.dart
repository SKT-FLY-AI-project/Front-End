class ConversationModel {
  final int id;
  final int artworkId;
  final String message;
  final bool isUserMessage;
  final DateTime timestamp;

  ConversationModel({
    required this.id,
    required this.artworkId,
    required this.message,
    required this.isUserMessage,
    required this.timestamp,
  });

  // JSON 변환을 위한 팩토리 메서드
  factory ConversationModel.fromJson(Map<String, dynamic> json) {
    return ConversationModel(
      id: json['id'],
      artworkId: json['artworkId'],
      message: json['message'],
      isUserMessage: json['isUserMessage'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'artworkId': artworkId,
      'message': message,
      'isUserMessage': isUserMessage,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}