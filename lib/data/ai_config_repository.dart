import '../models/ai_config_model.dart';
import 'database_provider.dart';

class AiConfigRepository {
  final DatabaseProvider db;

  AiConfigRepository(this.db);

  Future<void> saveAiConfig(AiConfigModel config) async {
    final index = db.aiConfigTable.indexWhere((item) => item.id == config.id);
    if (index >= 0) {
      db.aiConfigTable[index] = config;
    } else {
      db.aiConfigTable.add(config);
    }
  }

  Future<AiConfigModel?> getAiConfig(int userId) async {
    final items = db.aiConfigTable.where((item) => item.userId == userId).toList();
    return items.isEmpty ? null : items.first;
  }
}
