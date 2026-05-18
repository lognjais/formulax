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
    final results = _rankedResults();
    if (query.trim().isNotEmpty) {
      AnalyticsService.logSearch(query.trim(), results.length);
    }
    return _buildList(context, precomputed: results);
  }

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  List<Formula> _rankedResults() {
    if (query.trim().isEmpty) return const [];
    if (service != null) return service!.search(query, limit: 50);
    final q = query.toLowerCase();
    return formulas.where((f) {
      return f.title.toLowerCase().contains(q) ||
          f.topic.toLowerCase().contains(q);
    }).toList();
  }

  Widget _buildList(BuildContext context, {List<Formula>? precomputed}) {
    final results = precomputed ?? _rankedResults();

    if (query.trim().isEmpty) {
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
            "No matches for \"$query\".\nTry different keywords.",
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
