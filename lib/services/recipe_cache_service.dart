import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/cache_lookup_result.dart';
import '../models/recipe.dart';
import 'search_text_service.dart';

class RecipeCacheService {
  RecipeCacheService(this._searchTextService);

  static const String cachePrefix = 'cached_search_';
  static const String cacheTimePrefix = 'cached_search_time_';
  static const String cacheQueriesKey = 'cached_search_queries';
  static const int maxCachedQueries = 5;
  static const Duration cacheTtl = Duration(days: 7);

  final SearchTextService _searchTextService;

  bool _isExpired(int? cachedTime) {
    if (cachedTime == null) {
      return true;
    }
    final int now = DateTime.now().millisecondsSinceEpoch;
    return now - cachedTime > cacheTtl.inMilliseconds;
  }

  Future<void> _removeCachedQuery(
    SharedPreferences prefs,
    String normalizedQuery,
  ) async {
    await prefs.remove('$cachePrefix$normalizedQuery');
    await prefs.remove('$cacheTimePrefix$normalizedQuery');

    final List<String> cachedQueries =
        prefs.getStringList(cacheQueriesKey) ?? <String>[];
    if (cachedQueries.remove(normalizedQuery)) {
      await prefs.setStringList(cacheQueriesKey, cachedQueries);
    }
  }

  Future<void> saveCachedResults(String query, List<Recipe> results) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String normalizedQuery = _searchTextService.normalize(query);
    final String encodedResults =
        jsonEncode(results.map((Recipe recipe) => recipe.toJson()).toList());

    await prefs.setString('$cachePrefix$normalizedQuery', encodedResults);
    await prefs.setInt(
      '$cacheTimePrefix$normalizedQuery',
      DateTime.now().millisecondsSinceEpoch,
    );

    final List<String> cachedQueries =
        prefs.getStringList(cacheQueriesKey) ?? <String>[];
    cachedQueries.remove(normalizedQuery);
    cachedQueries.insert(0, normalizedQuery);

    if (cachedQueries.length > maxCachedQueries) {
      final List<String> droppedQueries =
          cachedQueries.sublist(maxCachedQueries).toList();
      cachedQueries.removeRange(maxCachedQueries, cachedQueries.length);
      for (final String droppedQuery in droppedQueries) {
        await _removeCachedQuery(prefs, droppedQuery);
      }
    }

    await prefs.setStringList(cacheQueriesKey, cachedQueries);
  }

  Future<CacheLookupResult?> loadCachedResults(String query) async {
    final String normalizedQuery = _searchTextService.normalize(query);
    final List<Recipe>? exactResults =
        await loadExactCachedResults(normalizedQuery);

    if (exactResults != null) {
      return CacheLookupResult(
        results: exactResults,
        sourceQuery: normalizedQuery,
        isExactMatch: true,
      );
    }

    final List<String> cachedQueries = await getCachedQueries();
    for (final String cachedQuery in cachedQueries) {
      final bool isCandidate = cachedQuery.contains(normalizedQuery) ||
          normalizedQuery.contains(cachedQuery);
      if (!isCandidate) {
        continue;
      }

      final List<Recipe>? fallbackResults =
          await loadExactCachedResults(cachedQuery);
      if (fallbackResults == null) {
        continue;
      }

      return CacheLookupResult(
        results: fallbackResults,
        sourceQuery: cachedQuery,
        isExactMatch: false,
      );
    }

    return null;
  }

  Future<List<Recipe>?> loadExactCachedResults(String query) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String normalizedQuery = _searchTextService.normalize(query);
    final String? cachedJson =
        prefs.getString('$cachePrefix$normalizedQuery');
    final int? cachedTime =
        prefs.getInt('$cacheTimePrefix$normalizedQuery');

    if (cachedJson == null || _isExpired(cachedTime)) {
      if (cachedJson != null) {
        await _removeCachedQuery(prefs, normalizedQuery);
      }
      return null;
    }

    return _decodeRecipes(cachedJson);
  }

  Future<List<String>> getCachedQueries() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> cachedQueries =
        prefs.getStringList(cacheQueriesKey) ?? <String>[];
    if (cachedQueries.isEmpty) {
      return <String>[];
    }

    final List<String> validQueries = <String>[];
    for (final String cachedQuery in cachedQueries) {
      final int? cachedTime =
          prefs.getInt('$cacheTimePrefix$cachedQuery');
      if (_isExpired(cachedTime)) {
        await _removeCachedQuery(prefs, cachedQuery);
      } else {
        validQueries.add(cachedQuery);
      }
    }

    if (validQueries.length != cachedQueries.length) {
      await prefs.setStringList(cacheQueriesKey, validQueries);
    }

    return validQueries;
  }

  Future<void> clearCache() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> cachedQueries = await getCachedQueries();
    for (final String cachedQuery in cachedQueries) {
      await _removeCachedQuery(prefs, cachedQuery);
    }
    await prefs.remove(cacheQueriesKey);
  }

  List<Recipe> _decodeRecipes(String cachedJson) {
    final List<dynamic> jsonList = jsonDecode(cachedJson) as List<dynamic>;
    return jsonList
        .map((dynamic item) => Recipe.fromJson(item as Map<String, dynamic>))
        .toList();
  }
}
