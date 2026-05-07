import 'package:flutter/material.dart';

class RecipeCategoryInfo {
  const RecipeCategoryInfo({
    required this.emoji,
    required this.label,
    required this.gradientColors,
  });

  final String emoji;
  final String label;
  final List<Color> gradientColors;
}

class RecipeCategory {
  RecipeCategory._();

  static const Map<String, RecipeCategoryInfo> _categoryMap =
      <String, RecipeCategoryInfo>{
    'trứng': RecipeCategoryInfo(
      emoji: '🍳',
      label: 'Trứng',
      gradientColors: <Color>[Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
    ),
    'gà': RecipeCategoryInfo(
      emoji: '🍗',
      label: 'Gà',
      gradientColors: <Color>[Color(0xFFFCE4EC), Color(0xFFF8BBD0)],
    ),
    'heo': RecipeCategoryInfo(
      emoji: '🥩',
      label: 'Heo',
      gradientColors: <Color>[Color(0xFFFFEBEE), Color(0xFFEF9A9A)],
    ),
    'bò': RecipeCategoryInfo(
      emoji: '🥘',
      label: 'Bò',
      gradientColors: <Color>[Color(0xFFFBE9E7), Color(0xFFFFCCBC)],
    ),
    'tôm': RecipeCategoryInfo(
      emoji: '🍤',
      label: 'Tôm',
      gradientColors: <Color>[Color(0xFFFFF3E0), Color(0xFFFFCC80)],
    ),
    'cá': RecipeCategoryInfo(
      emoji: '🐟',
      label: 'Cá',
      gradientColors: <Color>[Color(0xFFE3F2FD), Color(0xFF90CAF9)],
    ),
    'mực': RecipeCategoryInfo(
      emoji: '🦑',
      label: 'Hải sản',
      gradientColors: <Color>[Color(0xFFE8EAF6), Color(0xFF9FA8DA)],
    ),
    'nghêu': RecipeCategoryInfo(
      emoji: '🐚',
      label: 'Hải sản',
      gradientColors: <Color>[Color(0xFFE0F7FA), Color(0xFF80DEEA)],
    ),
    'sò': RecipeCategoryInfo(
      emoji: '🦪',
      label: 'Hải sản',
      gradientColors: <Color>[Color(0xFFE0F7FA), Color(0xFF80DEEA)],
    ),
    'cua': RecipeCategoryInfo(
      emoji: '🦀',
      label: 'Hải sản',
      gradientColors: <Color>[Color(0xFFFFF3E0), Color(0xFFFFCC80)],
    ),
    'đậu hũ': RecipeCategoryInfo(
      emoji: '🧈',
      label: 'Chay',
      gradientColors: <Color>[Color(0xFFF1F8E9), Color(0xFFC5E1A5)],
    ),
    'nấm': RecipeCategoryInfo(
      emoji: '🍄',
      label: 'Nấm',
      gradientColors: <Color>[Color(0xFFEFEBE9), Color(0xFFBCAAA4)],
    ),
    'rau': RecipeCategoryInfo(
      emoji: '🥬',
      label: 'Rau',
      gradientColors: <Color>[Color(0xFFE8F5E9), Color(0xFFA5D6A7)],
    ),
    'cải': RecipeCategoryInfo(
      emoji: '🥬',
      label: 'Rau',
      gradientColors: <Color>[Color(0xFFE8F5E9), Color(0xFFA5D6A7)],
    ),
    'bún': RecipeCategoryInfo(
      emoji: '🍜',
      label: 'Bún / Phở',
      gradientColors: <Color>[Color(0xFFFFF8E1), Color(0xFFFFE082)],
    ),
    'phở': RecipeCategoryInfo(
      emoji: '🍜',
      label: 'Bún / Phở',
      gradientColors: <Color>[Color(0xFFFFF8E1), Color(0xFFFFE082)],
    ),
    'miến': RecipeCategoryInfo(
      emoji: '🍝',
      label: 'Miến',
      gradientColors: <Color>[Color(0xFFFFF8E1), Color(0xFFFFE082)],
    ),
    'cháo': RecipeCategoryInfo(
      emoji: '🥣',
      label: 'Cháo',
      gradientColors: <Color>[Color(0xFFFFFDE7), Color(0xFFFFF59D)],
    ),
    'cơm': RecipeCategoryInfo(
      emoji: '🍚',
      label: 'Cơm',
      gradientColors: <Color>[Color(0xFFFFFDE7), Color(0xFFFFF59D)],
    ),
  };

  static final RecipeCategoryInfo _defaultCategory = RecipeCategoryInfo(
    emoji: '🍽️',
    label: 'Món ăn',
    gradientColors: <Color>[Color(0xFFF5F5F5), Color(0xFFE0E0E0)],
  );

  /// Detect category from recipe name and ingredients.
  static RecipeCategoryInfo detect(String name, List<String> ingredients) {
    final String lowerName = name.toLowerCase();
    final String allText =
        '$lowerName ${ingredients.join(' ').toLowerCase()}';

    // Check name first for more specific matches
    for (final MapEntry<String, RecipeCategoryInfo> entry
        in _categoryMap.entries) {
      if (lowerName.contains(entry.key)) {
        return entry.value;
      }
    }

    // Then check all text (name + ingredients)
    for (final MapEntry<String, RecipeCategoryInfo> entry
        in _categoryMap.entries) {
      if (allText.contains(entry.key)) {
        return entry.value;
      }
    }

    return _defaultCategory;
  }
}
