class InlineMathSegment {
  final String content;
  final bool isMath;
  const InlineMathSegment(this.content, this.isMath);

  @override
  bool operator ==(Object other) =>
      other is InlineMathSegment &&
      other.content == content &&
      other.isMath == isMath;

  @override
  int get hashCode => Object.hash(content, isMath);

  @override
  String toString() => "InlineMathSegment($content, isMath=$isMath)";
}

class InlineMathParser {
  InlineMathParser._();

  static final RegExp _regex = RegExp(r'(\\\((.*?)\\\))|(\$(.*?)\$)');

  static List<InlineMathSegment> parse(String input) {
    if (input.isEmpty) return const [];

    final segments = <InlineMathSegment>[];
    int lastMatchEnd = 0;

    for (final match in _regex.allMatches(input)) {
      if (match.start > lastMatchEnd) {
        segments.add(InlineMathSegment(
          input.substring(lastMatchEnd, match.start),
          false,
        ));
      }
      final mathContent = match.group(2) ?? match.group(4) ?? "";
      segments.add(InlineMathSegment(mathContent, true));
      lastMatchEnd = match.end;
    }

    if (lastMatchEnd < input.length) {
      segments.add(InlineMathSegment(input.substring(lastMatchEnd), false));
    }
    return segments;
  }
}
