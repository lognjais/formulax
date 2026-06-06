import 'dart:async';
import 'package:flutter/material.dart';
import '../models/formula.dart';
import '../screens/formula_detail_screen.dart';
import '../services/analytics_service.dart';
import '../services/formula_search_service.dart';

class FormulaSearchDelegate extends SearchDelegate {
  final List<Formula> formulas;
  final FormulaSearchService? service;

  FormulaSearchDelegate(this.formulas, {this.service});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(icon: const Icon(Icons.clear), onPressed: () => query = '')
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null));
  }

  @override
  Widget buildResults(BuildContext context) {
    final results = _rankedResultsFor(query);
    if (query.trim().isNotEmpty) {
      AnalyticsService.logSearch(query.trim(), results.length);
    }
    return _resultsList(context, query, results);
  }

  // Live suggestions are debounced so we don't rank 3,518 docs on every keystroke.
  @override
  Widget buildSuggestions(BuildContext context) {
    return _DebouncedResults(
      query: query,
      compute: _rankedResultsFor,
      builder: _resultsList,
    );
  }

  List<Formula> _rankedResultsFor(String q) {
    if (q.trim().isEmpty) return const [];
    if (service != null) return service!.search(q, limit: 50);
    final lower = q.toLowerCase();
    return formulas
        .where((f) =>
            f.title.toLowerCase().contains(lower) ||
            f.topic.toLowerCase().contains(lower))
        .toList();
  }

  Widget _resultsList(BuildContext context, String q, List<Formula> results) {
    if (q.trim().isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(32),
          child: Text(
            "Try: 'weight on incline', 'photon energy', 'mitosis stages'",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white54),
          ),
        ),
      );
    }
    if (results.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            "No matches for \"$q\".\nTry different keywords.",
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white54),
          ),
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (context, index) {
        final formula = results[index];
        return ListTile(
          title: Text(formula.title),
          subtitle: Text("${formula.subject} • ${formula.topic}"),
          trailing: const Icon(Icons.north_west, size: 16),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => FormulaDetailScreen(formula: formula)),
            );
          },
        );
      },
    );
  }
}

/// Debounces ranking: rapid keystrokes only trigger one search after a pause.
class _DebouncedResults extends StatefulWidget {
  final String query;
  final List<Formula> Function(String) compute;
  final Widget Function(BuildContext, String, List<Formula>) builder;
  const _DebouncedResults({
    required this.query,
    required this.compute,
    required this.builder,
  });

  @override
  State<_DebouncedResults> createState() => _DebouncedResultsState();
}

class _DebouncedResultsState extends State<_DebouncedResults> {
  static const _delay = Duration(milliseconds: 180);
  Timer? _timer;
  late String _settled;

  @override
  void initState() {
    super.initState();
    _settled = widget.query;
  }

  @override
  void didUpdateWidget(_DebouncedResults old) {
    super.didUpdateWidget(old);
    if (widget.query != old.query) {
      _timer?.cancel();
      // Empty query updates instantly (clearing); otherwise debounce.
      if (widget.query.trim().isEmpty) {
        _settled = widget.query;
      } else {
        _timer = Timer(_delay, () {
          if (mounted) setState(() => _settled = widget.query);
        });
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.builder(context, _settled, widget.compute(_settled));
  }
}
