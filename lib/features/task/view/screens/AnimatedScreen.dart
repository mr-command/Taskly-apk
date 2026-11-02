
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';


class AnimatedScreen extends ConsumerWidget {
  const AnimatedScreen({super.key});

  @override
  Widget build(BuildContext context,WidgetRef ref) {
    return  Center(
      child: Container(
        width: 250,
        height: 250,
        child: Lottie.asset(
          "assets/animations/NotesDocument.json"
        ),
      ),
    );
  }
}
