import '../models/recipe.dart';

class SearchTextService {
  static const Map<String, String> _viMap = <String, String>{
    'à': 'a',
    'á': 'a',
    'ạ': 'a',
    'ả': 'a',
    'ã': 'a',
    'â': 'a',
    'ầ': 'a',
    'ấ': 'a',
    'ậ': 'a',
    'ẩ': 'a',
    'ẫ': 'a',
    'ă': 'a',
    'ằ': 'a',
    'ắ': 'a',
    'ặ': 'a',
    'ẳ': 'a',
    'ẵ': 'a',
    'è': 'e',
    'é': 'e',
    'ẹ': 'e',
    'ẻ': 'e',
    'ẽ': 'e',
    'ê': 'e',
    'ề': 'e',
    'ế': 'e',
    'ệ': 'e',
    'ể': 'e',
    'ễ': 'e',
    'ì': 'i',
    'í': 'i',
    'ị': 'i',
    'ỉ': 'i',
    'ĩ': 'i',
    'ò': 'o',
    'ó': 'o',
    'ọ': 'o',
    'ỏ': 'o',
    'õ': 'o',
    'ô': 'o',
    'ồ': 'o',
    'ố': 'o',
    'ộ': 'o',
    'ổ': 'o',
    'ỗ': 'o',
    'ơ': 'o',
    'ờ': 'o',
    'ớ': 'o',
    'ợ': 'o',
    'ở': 'o',
    'ỡ': 'o',
    'ù': 'u',
    'ú': 'u',
    'ụ': 'u',
    'ủ': 'u',
    'ũ': 'u',
    'ư': 'u',
    'ừ': 'u',
    'ứ': 'u',
    'ự': 'u',
    'ử': 'u',
    'ữ': 'u',
    'ỳ': 'y',
    'ý': 'y',
    'ỵ': 'y',
    'ỷ': 'y',
    'ỹ': 'y',
    'đ': 'd',
  };

  String normalize(String input) {
    final String lower = input.toLowerCase().trim();
    final StringBuffer normalized = StringBuffer();
    for (final String ch in lower.split('')) {
      normalized.write(_viMap[ch] ?? ch);
    }
    return normalized.toString().replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  List<String> _splitTokens(String normalizedQuery) {
    if (normalizedQuery.isEmpty) {
      return <String>[];
    }

    final bool hasComma = normalizedQuery.contains(',');
    final List<String> parts = hasComma
        ? normalizedQuery.split(',')
        : normalizedQuery.split(RegExp(r'\s+'));

    return parts
        .map((String part) => part.trim())
        .where((String part) => part.isNotEmpty)
        .toList();
  }

  bool matches(Recipe recipe, String normalizedQuery) {
    final List<String> tokens = _splitTokens(normalizedQuery);
    if (tokens.isEmpty) {
      return false;
    }

    final String name = normalize(recipe.name);
    final List<String> normalizedIngredients = recipe.ingredients
        .map((String ingredient) => normalize(ingredient))
        .toList();

    bool matchesToken(String token) {
      if (name.contains(token)) {
        return true;
      }
      return normalizedIngredients
          .any((String ingredient) => ingredient.contains(token));
    }

    return tokens.every(matchesToken);
  }
}
