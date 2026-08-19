import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:base_app/core/services/cach_helper/cache_helper.dart';
import 'package:riverpod/legacy.dart';

const String _kSearchHistoryKey = 'search_history_list';

final searchHistoryProvider = StateNotifierProvider<SearchHistoryNotifier, List<String>>((ref) {
  return SearchHistoryNotifier();
});

class SearchHistoryNotifier extends StateNotifier<List<String>> {
  SearchHistoryNotifier() : super([]) {
    _loadHistory();
  }

  void _loadHistory() {
    final history = CacheHelper.getStringList(_kSearchHistoryKey) ?? [];
    state = history;
  }

  Future<void> addQuery(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return;

    List<String> updated = List.from(state);
    // Remove if exists to move to top
    updated.removeWhere((item) => item.toLowerCase() == trimmed.toLowerCase());
    updated.insert(0, trimmed);

    // Limit history to 15 items max
    if (updated.length > 15) {
      updated = updated.sublist(0, 15);
    }

    state = updated;
    await CacheHelper.setStringList(_kSearchHistoryKey, updated);
  }

  Future<void> removeQuery(String query) async {
    final updated = List<String>.from(state)..remove(query);
    state = updated;
    await CacheHelper.setStringList(_kSearchHistoryKey, updated);
  }

  Future<void> clearAll() async {
    state = [];
    await CacheHelper.remove(_kSearchHistoryKey);
  }
}
