import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/database/app_database.dart';
import 'package:the_best_todo/core/database/database_provider.dart';

/// All note mutations funnel through here.
class NoteRepository {
  NoteRepository(this._db);

  final AppDatabase _db;

  Stream<List<NoteData>> watchAll() => _db.selectNotes();

  Future<void> add({
    required String title,
    required String content,
  }) {
    return _db.createNote(title, content);
  }

  Future<void> delete(int id) => _db.deleteNote(id);
}

final noteRepositoryProvider =
    Provider<NoteRepository>((ref) => NoteRepository(ref.watch(dbProvider)));

final watchNotesProvider = StreamProvider<List<NoteData>>((ref) {
  return ref.watch(noteRepositoryProvider).watchAll();
});
