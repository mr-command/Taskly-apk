import 'package:the_best_todo/core/providers.dart';

// import 'package:drift/drift.dart';

void addTask(String title,ref) {

  final db = ref.read(dbProvider);

  db.createTask(title);

}


void addNote(String title,ref,String content) {

  final db = ref.read(dbProvider);

  db.createNote(title,content);

}

// loadTasks(WidgetRef ref) async {

//   final db = ref.read(dbProvider);

//   final tasks = await db.selectTasks();

//   return tasks;

// }


void updateTask(String title) async {
  
}



void deleteTask(String title) {
  

}