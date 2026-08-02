
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/components/cards.dart';
import 'package:the_best_todo/core/providers.dart';

class All extends ConsumerWidget {
  const All({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    final tasks = ref.watch(tasksProvider);
    return  tasks.when(
      data: (tasks) {
        return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              
              final task = tasks[index];

              return TaskCard(task,ref,context,task.id);

              
          },
        );
        
      },
      loading: () => const CircularProgressIndicator(),
      error: (e, _) => Text(e.toString()),
      
    );      
  }
}
