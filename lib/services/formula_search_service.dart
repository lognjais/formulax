import 'dart:math' as math;
import '../models/formula.dart';

class FormulaSearchService {
  static const double _k1 = 1.5;
  static const double _b = 0.75;

  static const Set<String> _stopwords = {
    'a', 'an', 'the', 'is', 'are', 'was', 'were', 'be', 'been', 'being',
    'to', 'of', 'in', 'on', 'at', 'for', 'with', 'by', 'from', 'as',
    'and', 'or', 'but', 'if', 'then', 'else', 'this', 'that', 'these',
    'those', 'it', 'its', 'they', 'them', 'we', 'us', 'our',
    'what', 'which', 'who', 'whom', 'when', 'where', 'why', 'how',
    'do', 'does', 'did', 'doing', 'have', 'has', 'had', 'having',
  };

  final List<Formula> _formulas;
  final Map<String, List<String>> _synonyms;

  late final List<List<String>> _docTokens;
  late final Map<String, int> _docFreq;
  late final double _avgDocLen;

  FormulaSearchService(this._formulas, {Map<String, List<String>>? synonyms})
      : _synonyms = synonyms ?? const {} {
    _buildIndex();
  }

  void _buildIndex() {
    _docTokens = _formulas.map(_docTextOf).map(tokenize).toList();
    _docFreq = {};
    for (final tokens in _docTokens) {
      for (final term in tokens.toSet()) {
        _docFreq[term] = (_docFreq[term] ?? 0) + 1;
      }
    }
    _avgDocLen = _docTokens.isEmpty
        ? 0
        : _docTokens.map((t) => t.length).reduce((a, b) => a + b) /
            _docTokens.length;
  }

  String _docTextOf(Formula f) {
    final concepts = f.relatedConcepts
        .map((c) => '${c.name} ${c.definition}')
        .join(' ');
    return '${f.title} ${f.topic} ${f.subject} '
        '${f.description} ${f.derivation ?? ''} $concepts';
  }

  static List<String> tokenize(String input) {
    final lowered = input.toLowerCase();
    final raw = lowered.split(RegExp(r'[^a-z0-9]+'));
    return raw.where((t) => t.isNotEmpty && !_stopwords.contains(t)).toList();
  }

  List<String> _expandQuery(List<String> queryTokens) {
    final expanded = <String>[];
    for (final token in queryTokens) {
      expanded.add(token);
      final syns = _synonyms[token];
      if (syns != null) expanded.addAll(syns);
    }
    return expanded;
  }

  List<Formula> search(String query, {int limit = 50}) {
    final qTokens = tokenize(query);
    if (qTokens.isEmpty) return const [];

    final expandedTokens = _expandQuery(qTokens);
    final N = _formulas.length;

    final scores = <int, double>{};
    for (int i = 0; i < _formulas.length; i++) {
      final doc = _docTokens[i];
      if (doc.isEmpty) continue;
      double score = 0;
      for (final term in expandedTokens) {
        final tf = doc.where((t) => t == term).length;
        if (tf == 0) continue;
        final df = _docFreq[term] ?? 0;
        final idf = math.log(((N - df + 0.5) / (df + 0.5)) + 1);
        final numerator = tf * (_k1 + 1);
        final denom = tf + _k1 * (1 - _b + _b * (doc.length / _avgDocLen));
        score += idf * (numerator / denom);
      }
      if (score > 0) scores[i] = score;
    }

    final ranked = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return ranked.take(limit).map((e) => _formulas[e.key]).toList();
  }
}
