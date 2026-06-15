import '../models/progress_model.dart';

class SrsScheduler {
  /// Вычисляет дату следующего повторения на основе SRS-стадии.
  /// Возвращает [nextReviewAt] в виде ISO-строки.
  String calculateNextReview(int srsStage) {
    final intervals = [1, 3, 7, 14, 30, 60, 120];
    final days = srsStage < intervals.length
        ? intervals[srsStage]
        : intervals.last;
    return DateTime.now().add(Duration(days: days)).toIso8601String();
  }

  /// Обновляет прогресс после ответа на вопрос.
  /// [correct] — true, если ответ верный.
  ProgressModel updateSrsAfterAnswer(ProgressModel progress, bool correct) {
    progress.seenCount++;
    if (correct) {
      progress.correctCount++;
      progress.srsStage++;
    } else {
      progress.wrongCount++;
      if (progress.srsStage > 0) progress.srsStage--;
    }
    progress.lastReviewedAt = DateTime.now().toIso8601String();
    progress.nextReviewAt = calculateNextReview(progress.srsStage);
    return progress;
  }
}
