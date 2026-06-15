class ProgressModel {
  final int id;
  final int userId;
  final int kanjiId;
  int seenCount;
  int correctCount;
  int wrongCount;
  int srsStage;
  String? nextReviewAt;
  String? lastReviewedAt;

  ProgressModel({
    required this.id,
    required this.userId,
    required this.kanjiId,
    this.seenCount = 0,
    this.correctCount = 0,
    this.wrongCount = 0,
    this.srsStage = 0,
    this.nextReviewAt,
    this.lastReviewedAt,
  });
}
