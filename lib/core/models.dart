import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'models.g.dart';

class Task extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean()();
}

@DriftDatabase(tables: [Task])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          driftDatabase(
            name: 'task_db',
            native: const DriftNativeOptions(),
          ),
        );

  @override
  int get schemaVersion => 1;

  Future<int> createTask(String title) {
    return into(task).insert(
      TaskCompanion.insert(
        title: title,
        isCompleted: false,
      ),
    );
  }

  Future<List<TaskData>> selectTasks() {
    return select(task).get();
  }
  Future<bool> updateTask(TaskData taskData) {
    return update(task).replace(taskData);
  }

  Future<int> updateTitleTask(int id, String title) {
    return (update(task)
          ..where((t) => t.id.equals(id)))
        .write(
      TaskCompanion(
        title: Value(title),
      ),
    );
  }

  // DELETE
  Future<int> deleteTask(int id) {
    return (delete(task)
          ..where((t) => t.id.equals(id)))
        .go();
  }
}

