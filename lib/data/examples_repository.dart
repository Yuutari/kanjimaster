import '../models/example_model.dart';
import 'database_provider.dart';

class ExamplesRepository {
  final DatabaseProvider db;

  ExamplesRepository(this.db);

  Future<List<ExampleModel>> getExamplesForKanji(int kanjiId) async {
    return db.examplesTable.where((item) => item.kanjiId == kanjiId).toList();
  }
}
