import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'models.g.dart';

class Task extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  BoolColumn get isCompleted => boolean()();
}


class Note extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get title => text()();
  TextColumn get content => text()();
}

@DriftDatabase(tables: [Task,Note])
class AppDatabase extends _$AppDatabase {
  AppDatabase()
      : super(
          driftDatabase(
            name: 'task_db',
            native: const DriftNativeOptions(),
          ),
        );

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },

    onUpgrade: (m, from, to) async {
      if (from < 2) {
        await m.createTable(note);
      }
    },
  );



  // ----------- Task ------------

  Future<int> createTask(String title) {
    return into(task).insert(
      TaskCompanion.insert(
        title: title,
        isCompleted: false,
      ),
    );
  }

  Stream<List<TaskData>> selectTasks() {
    return select(task).watch();
  }
  Future<bool> updateTask(TaskData taskData) {
    return update(task).replace(taskData);
  }

  Future<int> updateTitleTask(int id, String title) async {
    return await (update(task)
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

    // ----------- Note ------------

  Future<int> createNote(String title,String content) {
    return into(note).insert(
      NoteCompanion.insert(
        title: title,
        content: content,
      ),
    );
  }

  Stream<List<NoteData>> selectNotes() {
    return select(note).watch();
  }


}


