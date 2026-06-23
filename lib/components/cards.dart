import 'package:flutter/material.dart';
import 'package:the_best_todo/components/buttons.dart';
import 'package:the_best_todo/components/text_styles.dart';
import 'package:the_best_todo/core/models.dart';
import 'package:the_best_todo/core/providers.dart';



Widget TaskCard(TaskData task,ref,context) {
  final db = ref.read(dbProvider);
  return Container(
    margin: EdgeInsets.all(10),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Text(task.title,style: taskTitleTextSyle(context),),
          ],
        ),
    
    
        Row(
          children: [
            deleteTaskButton(context,task.id,ref),
            updateTaskButton(context),
            Checkbox(
              side: BorderSide(color: Theme.of(context).colorScheme.onPrimary),
              value: task.isCompleted,
              onChanged: (value) {
                db.updateTask(
                  task.copyWith(isCompleted: value ?? false),
                );
              },
            ),
          ],
        ),
      ],
    ),
  );
}