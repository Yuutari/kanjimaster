class AiConfigModel {
  final int id;
  final int userId;
  String difficulty;
  String focusMode;
  String updatedAt;

  AiConfigModel({
    required this.id,
    required this.userId,
    required this.difficulty,
    required this.focusMode,
    required this.updatedAt,
  });
}
