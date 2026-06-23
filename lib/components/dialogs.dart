import 'package:flutter/material.dart';
import 'package:the_best_todo/components/text_styles.dart';
import 'package:the_best_todo/core/CrudFuncs.dart';

Future<dynamic> showAddTaskDialog(BuildContext context,ref) {
  return showDialog(
    context: context,
    builder: (context) {
      final titlecontroller = TextEditingController();
      return Dialog(              
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(           
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Text(
                  "Add Task",
                  style: taskTitleTextSyle(context),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: titlecontroller,
                  style: labletaskTitleTextSyle(context),
                  decoration: InputDecoration(
                    
                    labelText: 'Task Title',
                    labelStyle: labletaskTitleTextSyle(context),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                        strokeAlign: 2,
                        width: 2
                        
                      )
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        strokeAlign: 2,
                        width: 2
                        
                      )
                    ),
                    disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                        strokeAlign: 2,
                        width: 2
                        
                      )
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                        strokeAlign: 2,
                        width: 2
                        
                      )
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: Size(100, 40)
                      ),
                      onPressed: () {

                      },
                      child: Text('Cancel',style: btntaskTitleTextSyle(context),),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: Size(100, 40)
                      ),
                      onPressed: () {
                        // TODO: Save task logic
                        addTask(titlecontroller.text,ref);
                        Navigator.pop(context);
                      },
                      child: Text('Add',style: btntaskTitleTextSyle(context),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

Future<dynamic> showEditTaskDialog(BuildContext context,ref) {
  return showDialog(
    context: context,
    builder: (context) {
      final titlecontroller = TextEditingController();
      return Dialog(              
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Material(           
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min, 
              children: [
                Text(
                  "Edit Task",
                  style: taskTitleTextSyle(context),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: titlecontroller,
                  style: labletaskTitleTextSyle(context),
                  decoration: InputDecoration(
                    
                    labelText: 'new Title',
                    labelStyle: labletaskTitleTextSyle(context),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                        strokeAlign: 2,
                        width: 2
                        
                      )
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Colors.grey,
                        strokeAlign: 2,
                        width: 2
                        
                      )
                    ),
                    disabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                        strokeAlign: 2,
                        width: 2
                        
                      )
                    ),
                    border: UnderlineInputBorder(
                      borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.onPrimary,
                        strokeAlign: 2,
                        width: 2
                        
                      )
                    ),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: Size(100, 40)
                      ),
                      onPressed: () {

                      },
                      child: Text('Cancel',style: btntaskTitleTextSyle(context),),
                    ),
                    SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        minimumSize: Size(100, 40)
                      ),
                      onPressed: () {
                        // TODO: Save task logic
                        addTask(titlecontroller.text,ref);
                        Navigator.pop(context);
                      },
                      child: Text('Apply',style: btntaskTitleTextSyle(context),),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}