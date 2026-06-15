class SessionModel {
  final int id;
  final int userId;
  final String sessionType;
  final int total;
  final int correct;
  final String createdAt;

  SessionModel({
    required this.id,
    required this.userId,
    required this.sessionType,
    required this.total,
    required this.correct,
    required this.createdAt,
  });
}
