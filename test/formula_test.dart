import 'package:flutter_test/flutter_test.dart';
import 'package:formulax/models/formula.dart';

void main() {
  group('Formula.fromJson', () {
    test('parses a complete formula entry', () {
      final json = {
        'id': 'phys_001',
        'subject': 'Physics',
        'topic': 'Mechanics',
        'title': 'Newton\'s Second Law',
        'visual_type': 'latex',
        'visual_data': r'F = ma',
        'description': 'Force equals mass times acceleration.',
        'derivation': 'Step 1\nStep 2',
        'related_concepts': [
          {'name': 'Inertia', 'definition': 'Resistance to change in motion.'}
        ],
      };

      final f = Formula.fromJson(json);

      expect(f.id, 'phys_001');
      expect(f.subject, 'Physics');
      expect(f.topic, 'Mechanics');
      expect(f.latex, 'F = ma');
      expect(f.derivation, 'Step 1\nStep 2');
      expect(f.relatedConcepts.length, 1);
      expect(f.relatedConcepts.first.name, 'Inertia');
    });

    test('defaults missing fields to empty strings/lists', () {
      final f = Formula.fromJson({});

      expect(f.id, '');
      expect(f.subject, '');
      expect(f.title, '');
      expect(f.visualType, 'latex');
      expect(f.visualData, '');
      expect(f.derivation, isNull);
      expect(f.relatedConcepts, isEmpty);
    });

    test('falls back from visual_data to latex key', () {
      final f = Formula.fromJson({'latex': r'E = mc^2'});
      expect(f.latex, 'E = mc^2');
    });

    test('handles null related_concepts gracefully', () {
      final f = Formula.fromJson({'related_concepts': null});
      expect(f.relatedConcepts, isEmpty);
    });
  });
}
