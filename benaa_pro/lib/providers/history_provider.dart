import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import '../core/api_client.dart';
import '../models/calculation_record.dart';

class HistoryNotifier extends StateNotifier<List<CalculationRecord>> {
  HistoryNotifier() : super([]);

  int _skip = 0;
  final int _limit = 20;
  bool hasMore = true;
  bool isLoading = false;

  Future<void> fetchHistory({bool refresh = false}) async {
    if (isLoading) return;
    if (refresh) {
      _skip = 0;
      hasMore = true;
    }
    if (!hasMore) return;

    isLoading = true;
    try {
      final response = await ApiClient.instance.get(
        '/calculations/history',
        queryParameters: {'skip': _skip, 'limit': _limit},
      );

      final List data = response.data['data'];
      final newRecords = data
          .map((item) => CalculationRecord.fromMap(item))
          .toList();

      if (newRecords.length < _limit) hasMore = false;

      state = refresh ? newRecords : [...state, ...newRecords];
      _skip += _limit;
    } finally {
      isLoading = false;
    }
  }
}

final historyProvider =
    StateNotifierProvider<HistoryNotifier, List<CalculationRecord>>(
      (ref) => HistoryNotifier(),
    );
