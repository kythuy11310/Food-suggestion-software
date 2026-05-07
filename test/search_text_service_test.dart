import 'package:flutter_test/flutter_test.dart';

import 'package:kitchen_search_flutter/models/recipe.dart';
import 'package:kitchen_search_flutter/services/search_text_service.dart';

void main() {
  group('SearchTextService', () {
    final SearchTextService service = SearchTextService();

    test('normalize bo dau tieng Viet', () {
      expect(service.normalize('  Tôm  '), 'tom');
      expect(service.normalize('TRỨNG'), 'trung');
      expect(service.normalize('đậu   hũ'), 'dau hu');
    });

    test('matches tim theo ten va nguyen lieu khong dau', () {
      const Recipe recipe = Recipe(
        id: 'r001',
        name: 'Canh bí đỏ nấu tôm',
        image: 'img',
        ingredients: <String>['bí đỏ', 'tôm', 'hành lá'],
        shortInstructions: 'Nấu chín rồi nêm vị.',
      );

      expect(service.matches(recipe, service.normalize('tom')), isTrue);
      expect(service.matches(recipe, service.normalize('bi do')), isTrue);
      expect(service.matches(recipe, service.normalize('kim chi')), isFalse);
    });

    test('matches nhieu nguyen lieu theo dau phay', () {
      const Recipe recipe = Recipe(
        id: 'r002',
        name: 'Canh ca chua tom',
        image: 'img',
        ingredients: <String>['ca chua', 'tom', 'hanh la'],
        shortInstructions: 'Nau chin.',
      );

      expect(service.matches(recipe, service.normalize('tom, ca chua')), isTrue);
      expect(service.matches(recipe, service.normalize('tom, thit')), isFalse);
    });
  });
}
