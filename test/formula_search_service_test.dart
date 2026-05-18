import 'package:flutter_test/flutter_test.dart';
import 'package:formulax/models/formula.dart';
import 'package:formulax/services/formula_search_service.dart';

Formula _f({
  required String id,
  required String title,
  required String topic,
  required String subject,
  String description = '',
  String? derivation,
}) {
  return Formula(
    id: id,
    subject: subject,
    topic: topic,
    title: title,
    description: description,
    visualType: 'latex',
    visualData: '',
    derivation: derivation,
    relatedConcepts: const [],
  );
}

void main() {
  group('tokenize', () {
    test('lowercases and splits on non-alphanumeric', () {
      expect(FormulaSearchService.tokenize("Newton's 2nd Law!"),
          ['newton', 's', '2nd', 'law']);
    });

    test('filters stopwords', () {
      expect(FormulaSearchService.tokenize('the force is on a body'),
          ['force', 'body']);
    });

    test('returns empty for empty input', () {
      expect(FormulaSearchService.tokenize(''), isEmpty);
    });
  });

  group('FormulaSearchService.search', () {
    final corpus = [
      _f(
        id: '1',
        subject: 'Physics',
        topic: 'Mechanics',
        title: 'Normal Force on Inclined Plane',
        description: 'Force perpendicular to the inclined surface.',
      ),
      _f(
        id: '2',
        subject: 'Physics',
        topic: 'Optics',
        title: 'Photon Energy',
        description: 'Energy of a photon is hf where h is Planck constant.',
      ),
      _f(
        id: '3',
        subject: 'Biology',
        topic: 'Cell Division',
        title: 'Mitosis Phases',
        description: 'Stages of mitosis: prophase, metaphase, anaphase.',
      ),
      _f(
        id: '4',
        subject: 'Physics',
        topic: 'Mechanics',
        title: 'Kinetic Energy',
        description: 'Energy of motion equals half mv squared.',
      ),
    ];

    test('returns empty for empty query', () {
      final svc = FormulaSearchService(corpus);
      expect(svc.search(''), isEmpty);
    });

    test('returns empty for query of only stopwords', () {
      final svc = FormulaSearchService(corpus);
      expect(svc.search('the and is'), isEmpty);
    });

    test('finds direct title matches', () {
      final svc = FormulaSearchService(corpus);
      final results = svc.search('photon energy');
      expect(results.first.id, '2');
    });

    test('ranks more relevant results higher', () {
      final svc = FormulaSearchService(corpus);
      final results = svc.search('energy');
      expect(results.first.id, anyOf(['2', '4']));
      expect(results.length, greaterThanOrEqualTo(2));
    });

    test('matches description text not just title', () {
      final svc = FormulaSearchService(corpus);
      final results = svc.search('planck');
      expect(results.first.id, '2');
    });

    test('synonym expansion finds related formulas', () {
      final svc = FormulaSearchService(
        corpus,
        synonyms: {
          'ramp': ['inclined', 'incline'],
        },
      );
      final results = svc.search('ramp');
      expect(results.isNotEmpty, isTrue);
      expect(results.first.id, '1');
    });

    test('returns empty for no matches', () {
      final svc = FormulaSearchService(corpus);
      expect(svc.search('xyzabc123'), isEmpty);
    });

    test('respects limit', () {
      final svc = FormulaSearchService(corpus);
      final results = svc.search('energy', limit: 1);
      expect(results.length, 1);
    });
  });
}
