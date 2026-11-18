import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/database/app_database.dart';
import 'package:the_best_todo/core/database/database_provider.dart';

class CategoryRepository {
  CategoryRepository(this._db);

  final AppDatabase _db;

  Stream<List<CategoryData>> watchAll() => _db.selectCategories();

  Future<void> add({
    required String name,
    required int color,
    required String iconKey,
    int sortOrder = 0,
  }) {
    return _db.createCategory(name, color, iconKey);
  }

  Future<void> update(CategoryData category) => _db.updateCategory(category);

  /// Tasks belonging to the category fall back to "Uncategorized".
  Future<void> delete(int id) => _db.deleteCategory(id);
}

final categoryRepositoryProvider = Provider<CategoryRepository>(
    (ref) => CategoryRepository(ref.watch(dbProvider)));

final watchCategoriesProvider =
    StreamProvider<List<CategoryData>>((ref) {
  return ref.watch(categoryRepositoryProvider).watchAll();
});
