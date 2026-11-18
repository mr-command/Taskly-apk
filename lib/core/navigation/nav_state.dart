import 'package:flutter_riverpod/flutter_riverpod.dart';

class TabIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void select(int index) {
    if (index == state) return;
    state = index;
  }
}

final selectedTabProvider =
    NotifierProvider<TabIndexNotifier, int>(TabIndexNotifier.new);
