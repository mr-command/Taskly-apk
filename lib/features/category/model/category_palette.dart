import 'package:flutter/material.dart';
import 'package:solar_icons/solar_icons.dart';

/// 12 curated category swatches — medium chroma so they read correctly on
/// both the light and dark background without competing over content.
const List<Color> categorySwatches = [
  Color(0xFF5A7BD6), // indigo blue
  Color(0xFF5BA367), // green
  Color(0xFFC47FD6), // violet
  Color(0xFFE8853D), // orange
  Color(0xFF4FA0A8), // teal
  Color(0xFFD96A6A), // rose
  Color(0xFF8FA65A), // olive
  Color(0xFF7B6FD1), // indigo
  Color(0xFFB08968), // brown
  Color(0xFF6E7681), // slate
  Color(0xFFA95C8F), // plum
  Color(0xFFD9B23A), // sand
];

/// Icon registry keyed by short string names (stored in the DB).
const Map<String, IconData> categoryIconRegistry = {
  'work': SolarIconsOutline.case_,
  'school': SolarIconsOutline.book2,
  'person': SolarIconsOutline.user,
  'project': SolarIconsOutline.folder,
  'home': SolarIconsOutline.home,
  'favorite': SolarIconsOutline.heart,
  'fitness': SolarIconsOutline.dumbbell,
  'shopping': SolarIconsOutline.cart,
  'book': SolarIconsOutline.notebook,
  'code': SolarIconsOutline.code,
  'music': SolarIconsOutline.musicNote,
  'travel': SolarIconsOutline.compassBig,
  'health': SolarIconsOutline.health,
  'sports': SolarIconsOutline.running,
  'pets': SolarIconsOutline.paw,
  'cafe': SolarIconsOutline.cupHot,
  'ideas': SolarIconsOutline.lamp,
  'money': SolarIconsOutline.wallet,
  'generic': SolarIconsOutline.widget,
  'star': SolarIconsOutline.star,
  'flag': SolarIconsOutline.flag,
  'trophy': SolarIconsOutline.medalStar,
  'games': SolarIconsOutline.gamepad,
  'goals': SolarIconsOutline.target,
};

IconData categoryIcon(String key) =>
    categoryIconRegistry[key] ?? categoryIconRegistry['generic']!;

/// Extension on the generated row class so every surface decodes the
/// stored ARGB int the same way.
extension CategoryColorX on int {
  Color get categoryColor => Color(this);
}

/// Tuple layout: (name, argb color, icon key) — seeded on first launch and
/// again during the v2 -> v3 migration.
const List<(String, int, String)> defaultCategories = [
  ('Work', 0xFF5A7BD6, 'work'),
  ('Study', 0xFF5BA367, 'school'),
  ('Personal', 0xFFC47FD6, 'person'),
  ('Project', 0xFFE8853D, 'project'),
];
