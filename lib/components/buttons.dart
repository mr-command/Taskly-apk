import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/components/dialogs.dart';
import 'package:the_best_todo/core/CrudFuncs.dart';
import '../core/providers.dart';

// toggle
Widget toggleButton(ThemeMode themeMode,WidgetRef ref,context){
  return IconButton(onPressed: (){
        themeMode == ThemeMode.dark
        ? ref.read(isDarkModeProvider.notifier).state = ThemeMode.light
        : ref.read(isDarkModeProvider.notifier).state = ThemeMode.dark;
      }, icon: Icon(themeMode == ThemeMode.dark
          ? Icons.light_mode_rounded
          : Icons.dark_mode,
          color: Theme.of(context).colorScheme.onPrimary
          ));
}

Widget addNoteButton(BuildContext context,WidgetRef ref){
  return IconButton(
    onPressed: () {
      showAddNoteDialog(context, ref);
    },
    icon: Icon(Icons.add),
    tooltip: "Add New Note",
    style: IconButton.styleFrom(
      backgroundColor: Theme.of(context).colorScheme.surface,
      foregroundColor: Theme.of(context).colorScheme.onSurface,
      fixedSize: Size(60, 60)
    ),
  );
}

Widget addTaskButton(BuildContext context,WidgetRef ref){
    return IconButton(
      hoverColor: Theme.of(context).colorScheme.secondaryContainer,
      onPressed: () => showAddTaskDialog(context,ref),
      icon: Icon(Icons.add),
      tooltip: "Add New task",
      style: IconButton.styleFrom(
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
        fixedSize: Size(50, 50)
      ),
    );
}

Widget deleteTaskButton(BuildContext context, int id, WidgetRef ref){
  return IconButton(
    onPressed: () {

      final db = ref.read(dbProvider);

      db.deleteTask(id);
      
    },
     icon: Icon(Icons.delete,color: Theme.of(context).colorScheme.onPrimary,)
  );
}

Widget updateTaskButton(BuildContext context,WidgetRef ref,int id){
  return IconButton(
    onPressed: () {

      showEditTaskDialog(context, ref,id);
      
    },
     icon: Icon(Icons.edit,color: Theme.of(context).colorScheme.onPrimary,)
  );
}