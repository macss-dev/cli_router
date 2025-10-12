part of 'cli_router.dart';

class _PathPattern {
  _PathPattern(this.segments);
  final List<_Segment> segments;

  static _PathPattern parse(String pattern, {bool allowParams = true}) {
    final parts = pattern
        .trim()
        .split(RegExp(r'\s+'))
        .where((e) => e.isNotEmpty)
        .toList();
    final segs = <_Segment>[];
    for (final p in parts) {
      if (allowParams && p.startsWith('<') && p.endsWith('>') && p.length > 2) {
        segs.add(_Segment.param(p.substring(1, p.length - 1)));
      } else if (allowParams && p == '*') {
        segs.add(_Segment.wildcard());
      } else {
        segs.add(_Segment.literal(p));
      }
    }
    return _PathPattern(segs);
  }

  bool matches(List<String> tokens, {required Map<String, String> outParams}) {
    final hasWildcard = segments.isNotEmpty && segments.last.isWildcard;
    if (!hasWildcard && tokens.length != segments.length) return false;
    if (hasWildcard && tokens.length < segments.length - 1) return false;

    for (int i = 0; i < segments.length; i++) {
      final seg = segments[i];
      if (seg.isWildcard) {
        return true;
      }
      if (i >= tokens.length) return false;
      final tok = tokens[i];
      if (seg.isParam) {
        outParams[seg.name] = tok;
      } else {
        if (tok != seg.literal) return false;
      }
    }
    return true;
  }

  @override
  String toString() =>
      segments.map((s) => s.isParam ? '<${s.name}>' : s.literal).join(' ');
}

class _Segment {
  _Segment._(this.literal, this.name, this.isParam, this.isWildcard);
  factory _Segment.literal(String v) => _Segment._(v, '', false, false);
  factory _Segment.param(String name) => _Segment._('', name, true, false);
  factory _Segment.wildcard() => _Segment._('*', '', false, true);

  final String literal;
  final String name;
  final bool isParam;
  final bool isWildcard;
}
