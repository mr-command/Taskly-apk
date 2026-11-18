import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:the_best_todo/features/category/model/category_palette.dart';

part 'app_database.g.dart';

/// Priority is stored as an int index of TaskPriority:
/// 0 = critical, 1 = high, 2 = medium (default), 3 = low.
@TableIndex(name: 'idx_task_category', columns: {#categoryId})
@TableIndex(name: 'idx_task_priority', columns: {#priority})
@TableIndex(name: 'idx_task_completed_at', columns: {#completedAt})
class Task extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean()();
  IntColumn get priority => integer().withDefault(const Constant(2))();
  IntColumn get categoryId => integer().nullable()();
  IntColumn get createdAt => integer().withDefault(const Constant(0))();
  IntColumn get completedAt => integer().nullable()();
}

class Note extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
  IntColumn get createdAt => integer().withDefault(const Constant(0))();
}

/// Icon is stored as a string key resolved through [categoryIconRegistry].
class Category extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().withLength(min: 1, max: 32)();
  IntColumn get color => integer()();
  TextColumn get icon => text()();
  IntColumn get sortOrder => integer().withDefault(const Constant(0))();
}

@DriftDatabase(tables: [Task, Note, Category])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
    : super(driftDatabase(name: 'task_db', native: const DriftNativeOptions()));

  @override
  int get schemaVersion => 4;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      await _seedDefaultCategories();
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Only when the notes table isn't there yet — a half-finished
        // earlier launch may have created it already.
        if (!await _tableExists('note')) {
          await m.createTable(note);
        }
      }
      if (from < 3) {
        if (!await _tableExists('category')) {
          await m.createTable(category);
        }

        // Drift keeps the SQL name of `Task` as 'task' (singular).
        if (await _tableExists('task')) {
          if (!await _columnExists('task', 'priority')) {
            await m.addColumn(task, task.priority);
          }
          if (!await _columnExists('task', 'category_id')) {
            await m.addColumn(task, task.categoryId);
          }
          if (!await _columnExists('task', 'created_at')) {
            await m.addColumn(task, task.createdAt);
          }
          if (!await _columnExists('task', 'completed_at')) {
            await m.addColumn(task, task.completedAt);
          }

          // Legacy rows had no creation timestamp: derive a stable,
          // order-preserving fake timestamp from the row id.
          await customStatement(
            'UPDATE task SET created_at = id * 86400000 WHERE created_at = 0',
          );
          // Legacy completions stay without completedAt so they never
          // fabricate spikes in the daily analytics buckets.
          await _seedDefaultCategories();
        }
      }
      if (from < 4) {
        // v3 of the Note table added created_at, but the v3 migration
        // never added it to existing databases. Any select on `note`
        // therefore failed, which made newly created notes invisible.
        if (await _tableExists('note') &&
            !await _columnExists('note', 'created_at')) {
          await m.addColumn(note, note.createdAt);
          await customStatement(
            'UPDATE note SET created_at = id * 86400000 WHERE created_at = 0',
          );
        }
      }
    },
  );

  Future<bool> _tableExists(String name) async {
    final rows = await customSelect(
      "SELECT 1 FROM sqlite_master WHERE type = 'table' AND name = ?",
      variables: [Variable.withString(name)],
    ).get();
    return rows.isNotEmpty;
  }

  Future<bool> _columnExists(String table, String column) async {
    final columns = await customSelect('PRAGMA table_info($table)').get();
    return columns.any((row) => row.data['name'] == column);
  }

  Future<void> _seedDefaultCategories() async {
    final existing = await select(category).get();
    if (existing.isNotEmpty) return;

    for (final def in defaultCategories) {
      await into(category).insert(
        CategoryCompanion.insert(
          name: def.$1,
          color: def.$2,
          icon: def.$3,
          sortOrder: const Value(0),
        ),
      );
    }
  }

  // ----------- Task ------------

  Future<int> createTask(String title) {
    return into(
      task,
    ).insert(TaskCompanion.insert(title: title, isCompleted: false));
  }

  Stream<List<TaskData>> selectTasks() {
    return select(task).watch();
  }

  Future<bool> updateTask(TaskData taskData) {
    return update(task).replace(taskData);
  }

  Future<int> updateTitleTask(int id, String title) async {
    return await (update(
      task,
    )..where((t) => t.id.equals(id))).write(TaskCompanion(title: Value(title)));
  }

  Future<int> deleteTask(int id) {
    return (delete(task)..where((t) => t.id.equals(id))).go();
  }

  // ----------- Note ------------

  Future<int> createNote(String title, String content) {
    return into(
      note,
    ).insert(NoteCompanion.insert(title: title, content: content));
  }

  Stream<List<NoteData>> selectNotes() {
    return select(note).watch();
  }

  Future<int> deleteNote(int id) async {
    final result = await (delete(note)..where((n) => n.id.equals(id))).go();
    return result;
  }

  // ----------- Category ------------

  Future<int> createCategory(String name, int color, String icon) {
    return into(
      category,
    ).insert(CategoryCompanion.insert(name: name, color: color, icon: icon));
  }

  Stream<List<CategoryData>> selectCategories() {
    return (select(category)..orderBy([
          (c) => OrderingTerm.asc(c.sortOrder),
          (c) => OrderingTerm.asc(c.id),
        ]))
        .watch();
  }

  Future<bool> updateCategory(CategoryData categoryData) {
    return update(category).replace(categoryData);
  }

  Future<int> deleteCategory(int id) async {
    await (update(task)..where((t) => t.categoryId.equals(id))).write(
      const TaskCompanion(categoryId: Value(null)),
    );
    return (delete(category)..where((c) => c.id.equals(id))).go();
  }
}
