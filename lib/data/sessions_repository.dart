import '../models/session_model.dart';
import 'database_provider.dart';

class SessionsRepository {
  final DatabaseProvider db;

  SessionsRepository(this.db);

  Future<void> saveSessionResult(SessionModel session) async {
    db.sessionsTable.add(session);
  }

  Future<List<SessionModel>> getSessionsHistory(int userId) async {
    return db.sessionsTable
        .where((item) => item.userId == userId)
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }
}
