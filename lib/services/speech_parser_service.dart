import '../models/app_config.dart';

class ParsedResult {
  final String category;
  final String type;
  final String value;

  const ParsedResult({
    required this.category,
    required this.type,
    required this.value,
  });
}

class SpeechParserService {
  const SpeechParserService();

  static final RegExp _wordPattern = RegExp(
    r'[\p{L}\p{N}]+(?:[.,][\p{L}\p{N}]+)*',
    unicode: true,
  );
  static final RegExp _edgePunctuation = RegExp(
    r'^[\p{P}\s]+|[\p{P}\s]+$',
    unicode: true,
  );

  List<ParsedResult> parse(String text, AppConfig config) {
    final tokens = _wordPattern
        .allMatches(text)
        .map(
          (match) => _SpeechToken(
            value: _normalize(match.group(0)!),
            start: match.start,
            end: match.end,
          ),
        )
        .toList();
    if (tokens.isEmpty) return const [];

    final markers = <_CommandMarker>[];
    for (final category in config.categories) {
      for (final type in category.types) {
        final markerTokens = [
          ..._wordPattern
              .allMatches(category.name)
              .map((match) => _normalize(match.group(0)!)),
          ..._wordPattern
              .allMatches(type)
              .map((match) => _normalize(match.group(0)!)),
        ];
        if (markerTokens.isNotEmpty) {
          markers.add(
            _CommandMarker(
              category: category.name,
              type: type,
              tokens: markerTokens,
            ),
          );
        }
      }
    }
    markers.sort((a, b) => b.tokens.length.compareTo(a.tokens.length));

    final starts = <_CommandStart>[];
    var tokenIndex = 0;
    while (tokenIndex < tokens.length) {
      _CommandMarker? match;
      for (final marker in markers) {
        if (_matchesAt(tokens, tokenIndex, marker.tokens)) {
          match = marker;
          break;
        }
      }

      if (match == null) {
        tokenIndex++;
        continue;
      }

      final endTokenIndex = tokenIndex + match.tokens.length;
      starts.add(
        _CommandStart(
          marker: match,
          startOffset: tokens[tokenIndex].start,
          nextTokenIndex: endTokenIndex,
        ),
      );
      tokenIndex = endTokenIndex;
    }

    return [
      for (var index = 0; index < starts.length; index++)
        ParsedResult(
          category: starts[index].marker.category,
          type: starts[index].marker.type,
          value: _extractValue(text, tokens, starts, index),
        ),
    ];
  }

  bool _matchesAt(
    List<_SpeechToken> textTokens,
    int start,
    List<String> markerTokens,
  ) {
    if (start + markerTokens.length > textTokens.length) return false;
    for (var index = 0; index < markerTokens.length; index++) {
      if (textTokens[start + index].value != markerTokens[index]) return false;
    }
    return true;
  }

  String _extractValue(
    String text,
    List<_SpeechToken> tokens,
    List<_CommandStart> starts,
    int commandIndex,
  ) {
    final command = starts[commandIndex];
    if (command.nextTokenIndex >= tokens.length) return '';

    final nextCommandStart = commandIndex + 1 < starts.length
        ? starts[commandIndex + 1].startOffset
        : text.length;
    final value = text
        .substring(tokens[command.nextTokenIndex].start, nextCommandStart)
        .replaceAll(_edgePunctuation, '')
        .trim();

    return value;
  }

  String _normalize(String value) =>
      value.replaceAll('İ', 'i').replaceAll('I', 'ı').toLowerCase();
}

class _SpeechToken {
  final String value;
  final int start;
  final int end;

  const _SpeechToken({
    required this.value,
    required this.start,
    required this.end,
  });
}

class _CommandMarker {
  final String category;
  final String type;
  final List<String> tokens;

  const _CommandMarker({
    required this.category,
    required this.type,
    required this.tokens,
  });
}

class _CommandStart {
  final _CommandMarker marker;
  final int startOffset;
  final int nextTokenIndex;

  const _CommandStart({
    required this.marker,
    required this.startOffset,
    required this.nextTokenIndex,
  });
}
