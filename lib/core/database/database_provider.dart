import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:the_best_todo/core/database/app_database.dart';

final dbProvider = Provider<AppDatabase>((ref) {
  return AppDatabase();
});
