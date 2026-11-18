import 'package:drift/drift.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/database/app_database.dart';
import 'package:the_best_todo/core/database/database_provider.dart';
import 'package:the_best_todo/features/priority/model/priority.dart';

/// All task mutations funnel through here so timestamps (createdAt,
/// completedAt) stay consistent, which is what the analytics depend on.
class TaskRepository {
  TaskRepository(this._db);

  final AppDatabase _db;

  int _now() => DateTime.now().millisecondsSinceEpoch;

  Stream<List<TaskData>> watchAll() => _db.selectTasks();

  Future<void> add({
    required String title,
    TaskPriority priority = TaskPriority.medium,
    int? categoryId,
  }) {
    return _db.into(_db.task).insert(
          TaskCompanion.insert(
            title: title,
            isCompleted: false,
            priority: Value(priority.index),
            categoryId: Value(categoryId),
            createdAt: Value(_now()),
          ),
        );
  }

  Future<void> setTitle(int id, String title) {
    return _db.updateTitleTask(id, title);
  }

  Future<void> toggleComplete(TaskData task, {bool? value}) {
    final done = value ?? !task.isCompleted;
    return _db.updateTask(
      TaskData(
        id: task.id,
        title: task.title,
        isCompleted: done,
        priority: task.priority,
        categoryId: task.categoryId,
        createdAt: task.createdAt,
        completedAt: done ? _now() : null,
      ),
    );
  }

  Future<void> setPriority(TaskData task, TaskPriority priority) {
    return _db.updateTask(
      TaskData(
        id: task.id,
        title: task.title,
        isCompleted: task.isCompleted,
        priority: priority.index,
        categoryId: task.categoryId,
        createdAt: task.createdAt,
        completedAt: task.completedAt,
      ),
    );
  }

  Future<void> setCategory(TaskData task, int? categoryId) {
    return _db.updateTask(
      TaskData(
        id: task.id,
        title: task.title,
        isCompleted: task.isCompleted,
        priority: task.priority,
        categoryId: categoryId,
        createdAt: task.createdAt,
        completedAt: task.completedAt,
      ),
    );
  }

  Future<void> delete(int id) => _db.deleteTask(id);
}

final taskRepositoryProvider =
    Provider<TaskRepository>((ref) => TaskRepository(ref.watch(dbProvider)));

final watchTasksProvider = StreamProvider<List<TaskData>>((ref) {
  return ref.watch(taskRepositoryProvider).watchAll();
});
