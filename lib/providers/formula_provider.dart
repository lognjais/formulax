import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/formula.dart';
import '../services/analytics_service.dart';
import '../services/content_metadata_service.dart';
import '../services/data_repository.dart';
import '../services/formula_search_service.dart';

class FormulaProvider with ChangeNotifier {
  List<Formula> _allFormulas = [];
  Map<String, Map<String, List<Formula>>> _structuredData = {};
  List<String> _bookmarkedIds = [];
  List<String> _revisedIds = [];
  bool _highYieldOnly = false;
  bool _isLoading = true;
  String? _errorMessage;
  FormulaSearchService? _searchService;
  final ContentMetadataService _metadata = ContentMetadataService();

  final DataRepository _repository = DataRepository();

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  List<Formula> get allFormulas => _allFormulas;
  FormulaSearchService? get searchService => _searchService;
  ContentMetadataService get metadata => _metadata;

  List<Formula> get bookmarkedFormulas =>
      _allFormulas.where((f) => _bookmarkedIds.contains(f.id)).toList();

  FormulaProvider() {
    load();
  }

  Future<void> load() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _bookmarkedIds = prefs.getStringList('bookmarked_formulas') ?? [];
      _revisedIds = prefs.getStringList('revised_formulas') ?? [];
      _highYieldOnly = prefs.getBool('high_yield_only') ?? false;

      final List<String> jsonStrings = await _repository.loadData();
      final synonyms = await _repository.loadSynonyms();
      await _metadata.load();
      final result = await compute(_parseAndGroupData, jsonStrings);

      _allFormulas = result.flatList;
      _structuredData = result.groupedData;

      if (_allFormulas.isEmpty) {
        _errorMessage = "No formulas found. Please reinstall the app.";
      } else {
        _searchService =
            FormulaSearchService(_allFormulas, synonyms: synonyms);
      }
    } catch (e) {
      debugPrint("Error in FormulaProvider.load: $e");
      _errorMessage = "Couldn't load formulas. Check your connection and retry.";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, List<Formula>> getTopicsForSubject(String subject) {
    return _structuredData[subject] ?? {};
  }

  List<Formula> getFormulasBySubject(String subject) {
    if (_structuredData.containsKey(subject)) {
      return _structuredData[subject]!.values.expand((list) => list).toList();
    }
    return [];
  }

  static ParsedData _parseAndGroupData(List<String> jsonStrings) {
    final List<Formula> flatList = [];
    final Map<String, Map<String, List<Formula>>> groupedData = {};

    for (String jsonString in jsonStrings) {
      try {
        final List<dynamic> parsed = json.decode(jsonString);
        for (var item in parsed) {
          final formula = Formula.fromJson(item);
          flatList.add(formula);

          groupedData.putIfAbsent(formula.subject, () => {});
          groupedData[formula.subject]!
              .putIfAbsent(formula.topic, () => [])
              .add(formula);
        }
      } catch (e) {
        debugPrint("Error parsing chunk in isolate: $e");
      }
    }
    return ParsedData(flatList, groupedData);
  }

  Future<void> toggleBookmark(String id) async {
    final adding = !_bookmarkedIds.contains(id);
    if (adding) {
      _bookmarkedIds.add(id);
    } else {
      _bookmarkedIds.remove(id);
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('bookmarked_formulas', _bookmarkedIds);
    unawaited(AnalyticsService.logBookmarkToggled(id, adding));
  }

  bool isBookmarked(String id) => _bookmarkedIds.contains(id);

  // ---- Revision tracking ----
  bool isRevised(String id) => _revisedIds.contains(id);

  int revisedCountIn(List<Formula> formulas) =>
      formulas.where((f) => _revisedIds.contains(f.id)).length;

  Future<void> toggleRevised(String id) async {
    if (!_revisedIds.remove(id)) _revisedIds.add(id);
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('revised_formulas', _revisedIds);
  }

  // ---- High-yield-only filter (persisted) ----
  bool get highYieldOnly => _highYieldOnly;

  Future<void> setHighYieldOnly(bool value) async {
    _highYieldOnly = value;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('high_yield_only', value);
  }
}

class ParsedData {
  final List<Formula> flatList;
  final Map<String, Map<String, List<Formula>>> groupedData;
  ParsedData(this.flatList, this.groupedData);
}
