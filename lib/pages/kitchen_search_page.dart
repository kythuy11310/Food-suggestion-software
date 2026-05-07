import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/cache_lookup_result.dart';
import '../models/recipe.dart';
import '../services/recipe_cache_service.dart';
import '../services/search_text_service.dart';
import '../utils/recipe_category.dart';
import 'recipe_detail_page.dart';

enum UiState { initial, loading, loaded, empty, error }

class KitchenSearchPage extends StatefulWidget {
  const KitchenSearchPage({super.key});

  @override
  State<KitchenSearchPage> createState() => _KitchenSearchPageState();
}

class _KitchenSearchPageState extends State<KitchenSearchPage> {
  static const String _historyKey = 'search_history';
  static const int _maxHistoryItems = 5;
  static const int _maxQueryLength = 50;

  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final SearchTextService _searchTextService = SearchTextService();

  late final RecipeCacheService _cacheService;

  List<Recipe> _allRecipes = <Recipe>[];
  List<Recipe> _filteredRecipes = <Recipe>[];
  List<String> _searchHistory = <String>[];
  UiState _uiState = UiState.initial;
  String _errorMessage = '';
  String _infoMessage = '';
  bool _isOfflineMode = false;
  bool _showHistory = false;
  bool _showCachePanel = false;
  int _cachedQueryCount = 0;
  List<String> _cachedQueries = <String>[];
  
  String _selectedCategory = 'Tất cả';
  final List<String> _categories = const <String>[
    'Tất cả',
    'Xào',
    'Canh',
    'Kho/Rim',
    'Nướng',
    'Chiên',
    'Hấp/Luộc',
    'Món nước',
    'Cháo',
    'Cơm',
    'Khác'
  ];

  @override
  void initState() {
    super.initState();
    _cacheService = RecipeCacheService(_searchTextService);
    _loadRecipes();
    _refreshCacheStats();
    _loadSearchHistory();
    _searchFocusNode.addListener(_handleSearchFocusChange);
    _searchController.addListener(_handleSearchInputChange);
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  Future<void> _loadRecipes() async {
    setState(() {
      _uiState = UiState.loading;
      _errorMessage = '';
    });

    try {
      final String jsonString =
          await rootBundle.loadString('assets/data/mock-recipes.json');
      final List<dynamic> jsonList = jsonDecode(jsonString) as List<dynamic>;
      final List<Recipe> recipes = jsonList
          .map((dynamic item) => Recipe.fromJson(item as Map<String, dynamic>))
          .toList();

      setState(() {
        _allRecipes = recipes;
        _filteredRecipes = recipes;
        _uiState = UiState.loaded;
      });
    } catch (_) {
      setState(() {
        _uiState = UiState.error;
        _errorMessage = 'Không tải được dữ liệu mẫu. Vui lòng thử lại.';
      });
    }
  }

  void _handleSearchFocusChange() {
    _refreshHistoryVisibility();
  }

  void _handleSearchInputChange() {
    _refreshHistoryVisibility();
  }

  bool _shouldShowHistory([List<String>? history]) {
    final List<String> data = history ?? _searchHistory;
    return _searchFocusNode.hasFocus &&
        _searchController.text.trim().isEmpty &&
        data.isNotEmpty;
  }

  void _refreshHistoryVisibility() {
    final bool shouldShow = _shouldShowHistory();
    if (_showHistory != shouldShow) {
      setState(() {
        _showHistory = shouldShow;
      });
    }
  }

  Future<void> _loadSearchHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final List<String> history =
        prefs.getStringList(_historyKey) ?? <String>[];

    if (!mounted) {
      return;
    }

    setState(() {
      _searchHistory = history;
      _showHistory = _shouldShowHistory(history);
    });
  }

  Future<void> _updateSearchHistory(String query) async {
    final String trimmed = query.trim();
    if (trimmed.isEmpty) {
      return;
    }

    final String normalized = _searchTextService.normalize(trimmed);
    final List<String> updated = <String>[trimmed];

    for (final String item in _searchHistory) {
      if (_searchTextService.normalize(item) == normalized) {
        continue;
      }
      updated.add(item);
    }

    if (updated.length > _maxHistoryItems) {
      updated.removeRange(_maxHistoryItems, updated.length);
    }

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, updated);

    if (!mounted) {
      return;
    }

    setState(() {
      _searchHistory = updated;
      _showHistory = _shouldShowHistory(updated);
    });
  }

  Future<void> _removeHistoryItem(String query) async {
    final String normalized = _searchTextService.normalize(query);
    final List<String> updated = _searchHistory
        .where(
          (String item) => _searchTextService.normalize(item) != normalized,
        )
        .toList();

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_historyKey, updated);

    if (!mounted) {
      return;
    }

    setState(() {
      _searchHistory = updated;
      _showHistory = _shouldShowHistory(updated);
    });
  }

  void _applyHistoryQuery(String query) {
    _searchController.text = query;
    _searchController.selection = TextSelection.fromPosition(
      TextPosition(offset: query.length),
    );
    _searchFocusNode.unfocus();

    setState(() {
      _showHistory = false;
    });

    _performSearch();
  }

  Future<void> _performSearch() async {
    final String rawQuery = _searchController.text.trim();
    final String normalizedQuery = _searchTextService.normalize(rawQuery);

    if (rawQuery.length > _maxQueryLength) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Từ khóa không được vượt quá 50 ký tự.'),
        ),
      );
      return;
    }

    if (normalizedQuery.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập ít nhất một nguyên liệu hoặc từ khóa.'),
        ),
      );
      return;
    }

    await _updateSearchHistory(rawQuery);

    setState(() {
      _uiState = UiState.loading;
      _errorMessage = '';
      _infoMessage = '';
      _showHistory = false;
    });

    if (_isOfflineMode) {
      final CacheLookupResult? cacheLookup =
          await _cacheService.loadCachedResults(normalizedQuery);

      if (!mounted) {
        return;
      }

      if (cacheLookup == null) {
        final List<String> cachedQueries =
            await _cacheService.getCachedQueries();
        final String cachedHint = cachedQueries.isEmpty
            ? 'Hiện chưa có cache nào.'
            : 'Các từ khóa đã cache: ${cachedQueries.join(', ')}';

        setState(() {
          _uiState = UiState.error;
          _errorMessage =
              'Bạn đang offline và chưa có dữ liệu cache cho từ khóa "$rawQuery". $cachedHint';
          _infoMessage = '';
        });
        return;
      }

      setState(() {
        _filteredRecipes = cacheLookup.results;
        _uiState =
            cacheLookup.results.isEmpty ? UiState.empty : UiState.loaded;
        _infoMessage = cacheLookup.isExactMatch
            ? '📦 Cache hit — "$normalizedQuery" (offline)'
            : '📦 Cache gần nhất: "${cacheLookup.sourceQuery}" (offline)';
      });
      return;
    }

    final List<Recipe>? exactCachedResults =
        await _cacheService.loadExactCachedResults(normalizedQuery);

    if (exactCachedResults != null) {
      if (!mounted) {
        return;
      }

      setState(() {
        _filteredRecipes = exactCachedResults;
        _uiState =
            exactCachedResults.isEmpty ? UiState.empty : UiState.loaded;
        _infoMessage =
            '⚡ Cache hit — ${exactCachedResults.length} món';
      });
      return;
    }

    await Future<void>.delayed(const Duration(milliseconds: 250));

    final List<Recipe> results = _allRecipes.where((Recipe recipe) {
      return _searchTextService.matches(recipe, normalizedQuery);
    }).toList();

    if (results.isNotEmpty) {
      await _cacheService.saveCachedResults(normalizedQuery, results);
      await _refreshCacheStats();
    }

    if (!mounted) {
      return;
    }

    setState(() {
      _filteredRecipes = results;
      _uiState = results.isEmpty ? UiState.empty : UiState.loaded;
      _infoMessage = results.isEmpty
          ? ''
          : '🔍 Tìm thấy ${results.length} món · đã lưu cache';
    });
  }

  Future<void> _refreshCacheStats() async {
    final List<String> cachedQueries = await _cacheService.getCachedQueries();
    if (!mounted) {
      return;
    }
    setState(() {
      _cachedQueryCount = cachedQueries.length;
      _cachedQueries = cachedQueries;
    });
  }

  Future<void> _clearCache() async {
    await _cacheService.clearCache();

    if (!mounted) {
      return;
    }

    setState(() {
      _cachedQueryCount = 0;
      _cachedQueries = <String>[];
      _infoMessage = '🗑️ Đã xóa toàn bộ cache.';
    });
  }

  void _handleRetry() {
    final String rawQuery = _searchController.text.trim();
    if (rawQuery.isEmpty) {
      _loadRecipes();
      return;
    }
    _performSearch();
  }

  void _clearSearch() {
    _searchController.clear();
    setState(() {
      _filteredRecipes = _allRecipes;
      _uiState = UiState.loaded;
      _infoMessage = '';
      _selectedCategory = 'Tất cả';
    });
  }

  void _openRecipeDetail(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeDetailPage(recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '🍽️ Kitchen Search',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(
              _isOfflineMode ? Icons.cloud_off : Icons.cloud_done_outlined,
              color: _isOfflineMode ? Colors.orange : null,
            ),
            tooltip: _isOfflineMode ? 'Offline mode' : 'Online mode',
            onPressed: () {
              setState(() {
                _isOfflineMode = !_isOfflineMode;
                _infoMessage = _isOfflineMode
                    ? '📴 Offline mode — chỉ đọc cache'
                    : '🌐 Online mode';
              });
            },
          ),
          IconButton(
            icon: Badge(
              isLabelVisible: _cachedQueryCount > 0,
              label: Text('$_cachedQueryCount'),
              child: const Icon(Icons.storage_outlined),
            ),
            tooltip: 'Cache: $_cachedQueryCount/${RecipeCacheService.maxCachedQueries}',
            onPressed: () {
              setState(() {
                _showCachePanel = !_showCachePanel;
              });
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            children: <Widget>[
              const SizedBox(height: 8),
              _buildSearchBar(),
              const SizedBox(height: 12),
              _buildCategoryFilter(),
              if (_showHistory) ...<Widget>[
                const SizedBox(height: 4),
                _buildHistoryPanel(),
              ],
              if (_showCachePanel) ...<Widget>[
                const SizedBox(height: 8),
                _buildCachePanel(),
              ],
              if (_infoMessage.isNotEmpty) ...<Widget>[
                const SizedBox(height: 8),
                _buildInfoBanner(),
              ],
              const SizedBox(height: 12),
              Expanded(child: _buildBody()),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _performSearch(),
            onTap: _refreshHistoryVisibility,
            decoration: InputDecoration(
              hintText: 'Tìm theo nguyên liệu: trứng, cà chua...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: _clearSearch,
                    )
                  : null,
            ),
          ),
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          onPressed: _performSearch,
          icon: const Icon(Icons.search, size: 20),
          label: const Text('Tìm'),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryFilter() {
    return SizedBox(
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (BuildContext context, int index) {
          final String category = _categories[index];
          final bool isSelected = _selectedCategory == category;
          return FilterChip(
            label: Text(category, style: const TextStyle(fontSize: 13)),
            selected: isSelected,
            onSelected: (bool selected) {
              setState(() {
                _selectedCategory = category;
              });
            },
            showCheckmark: false,
            selectedColor: const Color(0xFF0B6E4F).withValues(alpha: 0.2),
            labelStyle: TextStyle(
              color: isSelected ? const Color(0xFF0B6E4F) : Colors.grey[700],
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(
                color: isSelected ? const Color(0xFF0B6E4F) : Colors.grey[300]!,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE9F7F1),
        borderRadius: BorderRadius.circular(10),
        border:
            Border.all(color: const Color(0xFF0B6E4F).withValues(alpha: 0.25)),
      ),
      child: Text(
        _infoMessage,
        style: const TextStyle(color: Color(0xFF0B6E4F), fontSize: 13),
      ),
    );
  }

  Widget _buildHistoryPanel() {
    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD0D5DD)),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListView.separated(
        shrinkWrap: true,
        padding: EdgeInsets.zero,
        itemCount: _searchHistory.length,
        separatorBuilder: (_, __) => const Divider(height: 1),
        itemBuilder: (BuildContext context, int index) {
          final String query = _searchHistory[index];
          return InkWell(
            onTap: () => _applyHistoryQuery(query),
            borderRadius: index == 0
                ? const BorderRadius.vertical(top: Radius.circular(12))
                : index == _searchHistory.length - 1
                    ? const BorderRadius.vertical(bottom: Radius.circular(12))
                    : BorderRadius.zero,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.history, size: 18, color: Colors.grey),
                  const SizedBox(width: 10),
                  Expanded(child: Text(query)),
                  GestureDetector(
                    onTap: () => _removeHistoryItem(query),
                    child:
                        const Icon(Icons.close, size: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCachePanel() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE0E0E0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              const Icon(Icons.storage, size: 16),
              const SizedBox(width: 6),
              Text(
                'Cache: $_cachedQueryCount/${RecipeCacheService.maxCachedQueries}',
                style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
              ),
              const Spacer(),
              if (_cachedQueryCount > 0)
                TextButton.icon(
                  onPressed: _clearCache,
                  icon: const Icon(Icons.delete_outline, size: 16),
                  label: const Text('Xóa', style: TextStyle(fontSize: 12)),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                ),
            ],
          ),
          if (_cachedQueries.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                'Chưa có từ khóa nào.',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            )
          else
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: _cachedQueries
                    .map(
                      (String query) => ActionChip(
                        label: Text(query, style: const TextStyle(fontSize: 12)),
                        onPressed: () {
                          _searchController.text = query;
                          _performSearch();
                        },
                        visualDensity: VisualDensity.compact,
                      ),
                    )
                    .toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    switch (_uiState) {
      case UiState.initial:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('🍳', style: TextStyle(fontSize: 64)),
              const SizedBox(height: 16),
              Text(
                'Bạn muốn nấu gì hôm nay?',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Nhập nguyên liệu để tìm món ăn phù hợp',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[400],
                    ),
              ),
            ],
          ),
        );
      case UiState.loading:
        return const Center(child: CircularProgressIndicator());
      case UiState.empty:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('😔', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              const Text('Không tìm thấy món ăn nào.'),
              const SizedBox(height: 6),
              Text(
                'Thử lại với từ khóa khác nhé!',
                style: TextStyle(color: Colors.grey[500]),
              ),
            ],
          ),
        );
      case UiState.error:
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Text('⚠️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _handleRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        );
      case UiState.loaded:
        return _buildRecipeGrid();
    }
  }

  Widget _buildRecipeGrid() {
    final List<Recipe> sourceRecipes = _searchController.text.trim().isEmpty 
        ? _allRecipes 
        : _filteredRecipes;

    final List<Recipe> displayedRecipes = _selectedCategory == 'Tất cả'
        ? sourceRecipes
        : sourceRecipes
            .where((Recipe r) => r.category == _selectedCategory)
            .toList();

    if (displayedRecipes.isEmpty && sourceRecipes.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text('🔍', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 12),
            Text(
              'Không có món "$_selectedCategory" nào\ntrong kết quả tìm kiếm hiện tại.',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: () {
                setState(() => _selectedCategory = 'Tất cả');
              },
              child: const Text('Xem tất cả'),
            ),
          ],
        ),
      );
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final int crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: crossAxisCount == 2 ? 1.1 : 1.6,
          ),
          itemCount: displayedRecipes.length,
          itemBuilder: (BuildContext context, int index) {
            return _AnimatedRecipeCard(
              key: ValueKey<String>(displayedRecipes[index].id),
              recipe: displayedRecipes[index],
              index: index,
              onTap: () => _openRecipeDetail(displayedRecipes[index]),
            );
          },
        );
      },
    );
  }
}

class _AnimatedRecipeCard extends StatefulWidget {
  const _AnimatedRecipeCard({
    super.key,
    required this.recipe,
    required this.index,
    required this.onTap,
  });

  final Recipe recipe;
  final int index;
  final VoidCallback onTap;

  @override
  State<_AnimatedRecipeCard> createState() => _AnimatedRecipeCardState();
}

class _AnimatedRecipeCardState extends State<_AnimatedRecipeCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    Future<void>.delayed(Duration(milliseconds: widget.index * 80), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final RecipeCategoryInfo category =
        RecipeCategory.detect(widget.recipe.name, widget.recipe.ingredients);
    final ThemeData theme = Theme.of(context);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: widget.onTap,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                // Emoji header
                Expanded(
                  flex: 3,
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: category.gradientColors,
                      ),
                    ),
                    child: Center(
                      child: Hero(
                        tag: 'recipe_emoji_${widget.recipe.id}',
                        child: Material(
                          color: Colors.transparent,
                          child: Text(
                            category.emoji,
                            style: const TextStyle(fontSize: 52),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                // Content
                Expanded(
                  flex: 3,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          widget.recipe.name,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Expanded(
                          child: Wrap(
                            spacing: 4,
                            runSpacing: 4,
                            children: widget.recipe.ingredients
                                .take(4)
                                .map((String ing) => Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: theme
                                            .colorScheme.primaryContainer
                                            .withValues(alpha: 0.5),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        ing,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: theme.colorScheme
                                              .onPrimaryContainer,
                                        ),
                                      ),
                                    ))
                                .toList(),
                          ),
                        ),
                        Text(
                          widget.recipe.shortInstructions,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
