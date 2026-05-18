import 'package:flutter_test/flutter_test.dart';
import 'package:formulax/core/inline_math_parser.dart';

void main() {
  group('InlineMathParser.parse', () {
    test('returns empty list for empty input', () {
      expect(InlineMathParser.parse(''), isEmpty);
    });

    test('returns single text segment when no math', () {
      final result = InlineMathParser.parse('Plain prose with no math.');
      expect(result, hasLength(1));
      expect(result.first.isMath, isFalse);
      expect(result.first.content, 'Plain prose with no math.');
    });

    test('parses LaTeX \\(...\\) inline math', () {
      final result = InlineMathParser.parse(r'Where \(F = ma\) holds.');
      expect(result, hasLength(3));
      expect(result[0], const InlineMathSegment('Where ', false));
      expect(result[1], const InlineMathSegment('F = ma', true));
      expect(result[2], const InlineMathSegment(' holds.', false));
    });

    test(r'parses $...$ inline math', () {
      final result = InlineMathParser.parse(r'Energy $E = mc^2$ is famous.');
      expect(result, hasLength(3));
      expect(result[1].isMath, isTrue);
      expect(result[1].content, 'E = mc^2');
    });

    test('handles multiple math segments', () {
      final result =
          InlineMathParser.parse(r'\(a\) and \(b\) combine.');
      expect(result.where((s) => s.isMath).length, 2);
      expect(result.map((s) => s.content).toList(),
          ['a', ' and ', 'b', ' combine.']);
    });

    test('handles math at start of string', () {
      final result = InlineMathParser.parse(r'\(x\) is defined.');
      expect(result.first.isMath, isTrue);
      expect(result.first.content, 'x');
    });

    test('handles math at end of string', () {
      final result = InlineMathParser.parse(r'Value is \(42\)');
      expect(result.last.isMath, isTrue);
      expect(result.last.content, '42');
    });
  });
}
