import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_best_todo/core/database/app_database.dart';
import 'package:the_best_todo/core/navigation/app_shell.dart';
import 'package:the_best_todo/features/category/data/category_repository.dart';
import 'package:the_best_todo/features/notes/data/note_repository.dart';
import 'package:the_best_todo/features/tasks/data/task_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App shell renders tabs and Empty states', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          watchTasksProvider
              .overrideWith((ref) => Stream.value(<TaskData>[])),
          watchNotesProvider
              .overrideWith((ref) => Stream.value(<NoteData>[])),
          watchCategoriesProvider
              .overrideWith((ref) => Stream.value(<CategoryData>[])),
        ],
        child: const AppShell(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Taskly'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Insights'), findsOneWidget);
    expect(find.text('Categories'), findsOneWidget);
  });
}
