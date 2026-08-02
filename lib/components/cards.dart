import 'package:flutter/material.dart';
import 'package:the_best_todo/components/buttons.dart';
import 'package:the_best_todo/components/text_styles.dart';
import 'package:the_best_todo/core/models.dart';
import 'package:the_best_todo/core/providers.dart';



Widget TaskCard(TaskData task,ref,context,int index) {
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
            updateTaskButton(context,ref,index),
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


Widget NoteCard(BuildContext context,String title,String content){
  return Container(
    width: MediaQuery.widthOf(context) * 0.8,
    // height: 350,
    padding: EdgeInsets.all(15),
    margin: EdgeInsets.all(10),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(20),
      color: Theme.of(context).colorScheme.inversePrimary
    ),

    child: Column(

      children: [
        Text(title,style: taskTitleTextSyle(context),),
        SizedBox(height: 20,),
        Text(content,style: tasksubTitleTextSyle(context),),

      ],
    ),
  );
}