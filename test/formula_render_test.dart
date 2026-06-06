import 'dart:convert';
import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_math_fork/src/parser/tex/parser.dart';
import 'package:flutter_math_fork/src/parser/tex/settings.dart';
import 'package:formulax/core/inline_math_parser.dart';

/// Gold render-validation: every shipped LaTeX string must parse under the SAME
/// path the app uses (Math.tex -> TexParser(...).parse()). A failure here is a
/// red "LaTeX Error" box in production.
void main() {
  const files = ['physics', 'chemistry', 'math', 'biology'];

  String wrapBlock(String latex) {
    // Mirror FormulaDetailScreen._buildVisualContent array-wrap heuristic.
    if (latex.contains(r'\\') && !latex.contains(r'\begin')) {
      return r'\begin{array}{l}' + latex + r'\end{array}';
    }
    return latex;
  }

  bool parses(String expr) {
    try {
      TexParser(expr, const TexParserSettings()).parse();
      return true;
    } catch (_) {
      return false;
    }
  }

  test('every formula LaTeX (block + inline) renders without error', () {
    final failures = <String>[];
    final suffix = Platform.environment['FX_DATA_SUFFIX'] ?? '';
    for (final f in files) {
      final file = File('assets/data/$f$suffix.json');
      if (!file.existsSync()) continue;
      final list = json.decode(file.readAsStringSync()) as List<dynamic>;
      for (final item in list) {
        final m = item as Map<String, dynamic>;
        final id = m['id'] ?? '?';
        final vtype = m['visual_type'] ?? 'latex';
        // block formula
        if (vtype == 'latex') {
          final vd = (m['visual_data'] ?? m['latex'] ?? '') as String;
          if (vd.isNotEmpty && !parses(wrapBlock(vd))) {
            failures.add('$f/$id visual_data: $vd');
          }
        }
        // inline math in text fields
        final texts = <String>[
          (m['description'] ?? '') as String,
          (m['derivation'] ?? '') as String,
          ...((m['related_concepts'] as List<dynamic>?) ?? [])
              .map((c) => (c['definition'] ?? '') as String),
        ];
        for (final t in texts) {
          for (final seg in InlineMathParser.parse(t)) {
            if (seg.isMath && seg.content.trim().isNotEmpty && !parses(seg.content)) {
              failures.add('$f/$id inline: ${seg.content}');
            }
          }
        }
      }
    }
    if (failures.isNotEmpty) {
      // ignore: avoid_print
      print('LaTeX render failures (${failures.length}):\n${failures.join('\n')}');
    }
    expect(failures, isEmpty, reason: '${failures.length} LaTeX strings fail to parse');
  });
}
