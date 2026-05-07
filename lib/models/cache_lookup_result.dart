import 'recipe.dart';

class CacheLookupResult {
  const CacheLookupResult({
    required this.results,
    required this.sourceQuery,
    required this.isExactMatch,
  });

  final List<Recipe> results;
  final String sourceQuery;
  final bool isExactMatch;
}
