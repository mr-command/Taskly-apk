import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:the_best_todo/features/task/view_model/providers.dart';
import 'package:the_best_todo/main.dart';

void main() {
  testWidgets('app builds and shows Taskly home screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          tasksProvider.overrideWith((ref) => Stream.value([])),
          notesProvider.overrideWith((ref) => Stream.value([])),
        ],
        child: const MyApp(),
      ),
    );
    await tester.pump();

    expect(find.text('Taskly'), findsOneWidget);
  });
}
