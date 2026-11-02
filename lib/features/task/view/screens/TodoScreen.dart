import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:the_best_todo/features/task/view/components/buttons.dart';
import 'package:the_best_todo/features/task/view/components/text_styles.dart';
import 'package:the_best_todo/features/task/view/screens/AllTasks.dart';
import 'package:the_best_todo/features/task/view/screens/DoneTasks.dart';
import 'package:the_best_todo/features/task/view/screens/NoteScreen.dart';
import 'package:the_best_todo/features/task/view/screens/PendedTasks.dart';
import 'package:the_best_todo/features/task/view_model/providers.dart';


class Todoscreen extends ConsumerWidget {
  const Todoscreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    ThemeMode themeMode = ref.watch(isDarkModeProvider);
    // final tasksAsync = ref.watch(tasksProvider);
    final index = ref.watch(indexingScreens);

    List<Widget> screens = [
      Pended(),
      All(),
      Done(),
      Notescreen(),
    ];

    // ref.read(screensListProvider.notifier).state = screens;


    return Scaffold(
      appBar: AppBar(
        
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Taskly",style: mainHeaderTextStyle(context),),
            toggleButton(themeMode, ref,context)
          ],
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Container(
        padding: EdgeInsets.only(top: 25),
        color: Theme.of(context).colorScheme.primary,
        child: Container(
          padding: EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.only(topLeft: Radius.circular(40),topRight: Radius.circular(40)),
            color: Theme.of(context).scaffoldBackgroundColor
            
          ),
          child: screens[index]
        ),
      ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Container(
            width: MediaQuery.of(context).size.width * 0.82,
            // height: 60,
            padding: EdgeInsets.all(10),
            child: ClipRRect(
              borderRadius: BorderRadiusGeometry.circular(20),
              child: GNav(
                
                activeColor: Theme.of(context).colorScheme.onSurface,
                color: Theme.of(context).colorScheme.surface,
                tabBorderRadius: 40,
                backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                tabMargin: EdgeInsetsGeometry.only(left:10, right: 10),
                onTabChange: (value) {
                  ref.read(indexingScreens.notifier).state = value;

                },
                
                tabs: [
                  GButton(
                    padding: EdgeInsets.all(10),
                    gap:5,
                    icon: Icons.padding_outlined,
                    text: "Pended",
                    ),
                  GButton(
                    padding: EdgeInsets.all(10),
                    gap:5,
                    icon: Icons.note_alt_outlined,
                    text: "All",
                    ),
                  GButton(
                    padding: EdgeInsets.all(10),
                    gap:5,
                    icon: Icons.done_outline_rounded,
                    text: "Done",
                    ),
                  GButton(
                    padding: EdgeInsets.all(10),
                    gap:5,
                    icon: Icons.notes_outlined,
                    text: "Notes",
                    )
                ]
                ),
            ),
          ),
          
        ],
      ),
      floatingActionButton: index != 3
      ? addTaskButton(context, ref)
      : addNoteButton(context,ref)
    );
  }
}