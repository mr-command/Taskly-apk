import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/components/cards.dart';
import 'package:the_best_todo/core/providers.dart';



class Notescreen extends ConsumerWidget {
  const Notescreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ThemeMode themeMode = ref.watch(isDarkModeProvider);
    final notes = ref.watch(notesProvider);
    return notes.when(
      data: (notes) {
        return ListView.builder(
            itemCount: notes.length,
            itemBuilder: (context, index) {
              
              final note = notes[index];
              for (final note in notes) {
                print(
                  'NOTE => id: ${note.id}, title: ${note.title}',
                );
              }
              return NoteCard(context, note.title, note.content,ref,note.id);

              
          },
        );
      },
      error: (error, stackTrace) => Text("$error"),
      loading: () =>  Container(),);
  }
}