import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:kitchen_search_flutter/models/recipe.dart';
import 'package:kitchen_search_flutter/services/recipe_cache_service.dart';
import 'package:kitchen_search_flutter/services/search_text_service.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  group('RecipeCacheService', () {
    late SearchTextService searchTextService;
    late RecipeCacheService cacheService;

    setUp(() {
      searchTextService = SearchTextService();
      cacheService = RecipeCacheService(searchTextService);
    });

    test('luu va lay cache theo tu khoa chinh xac', () async {
      const Recipe recipe = Recipe(
        id: 'r100',
        name: 'Canh tom',
        image: 'img',
        ingredients: <String>['tom', 'hanh la'],
        shortInstructions: 'Nau chin roi nem vi.',
      );

      await cacheService.saveCachedResults('tôm', <Recipe>[recipe]);
      final result = await cacheService.loadCachedResults('tôm');

      expect(result, isNotNull);
      expect(result!.isExactMatch, isTrue);
      expect(result.results, hasLength(1));
      expect(result.results.first.name, 'Canh tom');
    });

    test('fallback cache khi khong co tu khoa chinh xac', () async {
      const Recipe recipe = Recipe(
        id: 'r101',
        name: 'Mi tom',
        image: 'img',
        ingredients: <String>['tom', 'mi'],
        shortInstructions: 'Nau nhanh.',
      );

      await cacheService.saveCachedResults('tom', <Recipe>[recipe]);
      final result = await cacheService.loadCachedResults('to');

      expect(result, isNotNull);
      expect(result!.isExactMatch, isFalse);
      expect(result.results.first.name, 'Mi tom');
    });

    test('chi giu toi da 5 truy van cache gan nhat', () async {
      for (int i = 1; i <= 6; i++) {
        final Recipe recipe = Recipe(
          id: 'r$i',
          name: 'Mon $i',
          image: 'img',
          ingredients: <String>['nguyen lieu $i'],
          shortInstructions: 'Huong dan $i',
        );
        await cacheService.saveCachedResults('mon $i', <Recipe>[recipe]);
      }

      final cachedQueries = await cacheService.getCachedQueries();
      expect(cachedQueries.length, RecipeCacheService.maxCachedQueries);
      expect(cachedQueries.contains(searchTextService.normalize('mon 1')), isFalse);
      expect(cachedQueries.first, searchTextService.normalize('mon 6'));
    });

    test('cache het han (TTL > 7 ngay) bi loai bo', () async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      const Recipe recipe = Recipe(
        id: 'r102',
        name: 'Thit luoc',
        image: 'img',
        ingredients: <String>['thit'],
        shortInstructions: 'Luoc.',
      );

      await cacheService.saveCachedResults('thit', <Recipe>[recipe]);
      
      // Giả lập thời gian lưu cache cách đây 8 ngày (7 ngày là hết hạn)
      final int eightDaysAgo = DateTime.now()
          .subtract(const Duration(days: 8))
          .millisecondsSinceEpoch;
      
      final String normalizedQuery = searchTextService.normalize('thit');
      await prefs.setInt('${RecipeCacheService.cacheTimePrefix}$normalizedQuery', eightDaysAgo);

      // Thử load lại
      final result = await cacheService.loadCachedResults('thit');
      
      // Kết quả phải là null do đã expired
      expect(result, isNull);
    });
  });
}
