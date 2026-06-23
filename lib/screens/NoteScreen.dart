import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';



class Notescreen extends ConsumerWidget {
  const Notescreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // ThemeMode themeMode = ref.watch(isDarkModeProvider);
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 400,
        crossAxisSpacing: 20,
        mainAxisExtent: 180,
        mainAxisSpacing: 20
        ),
        itemCount: 8,
        
       itemBuilder: (context, index) {
         return Container(
          width: 300,
          height: 70,

          decoration: BoxDecoration(

            border: Border.all(color: Theme.of(context).colorScheme.onPrimary)
          ),
         );
       },
    );
  }
}