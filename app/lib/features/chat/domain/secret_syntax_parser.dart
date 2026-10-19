import 'message_segment.dart';

enum _Marker {
  secret('||'),
  bold('**'),
  strike('~~'),
  italic('*');

  const _Marker(this.symbol);

  final String symbol;
}

abstract final class SecretSyntaxParser {
  static List<MessageSegment> parse(String text) {
    final open = <_Marker>{};
    final segments = <MessageSegment>[];
    final buffer = StringBuffer();

    void flush() {
      if (buffer.isEmpty) return;
      _append(
        segments,
        MessageSegment(
          buffer.toString(),
          secret: open.contains(_Marker.secret),
          bold: open.contains(_Marker.bold),
          italic: open.contains(_Marker.italic),
          strike: open.contains(_Marker.strike),
        ),
      );
      buffer.clear();
    }

    var i = 0;
    while (i < text.length) {
      final marker = _markerAt(text, i);
      if (marker == null) {
        buffer.write(text[i]);
        i++;
        continue;
      }

      final afterMarker = i + marker.symbol.length;
      if (open.contains(marker)) {
        flush();
        open.remove(marker);
        i = afterMarker;
        continue;
      }

      final closing = _findClosing(text, marker, afterMarker);
      if (closing == null || closing == afterMarker) {
        buffer.write(marker.symbol);
        i = afterMarker;
        continue;
      }

      flush();
      open.add(marker);
      i = afterMarker;
    }
    flush();
    return segments;
  }

  static bool hasSecret(String text) => parse(text).any((s) => s.secret);

  static _Marker? _markerAt(String text, int index) {
    for (final marker in _Marker.values) {
      if (marker == _Marker.italic && _isPartOfDoubleStar(text, index)) {
        continue;
      }
      if (text.startsWith(marker.symbol, index)) return marker;
    }
    return null;
  }

  static int? _findClosing(String text, _Marker marker, int from) {
    var index = text.indexOf(marker.symbol, from);
    while (index != -1) {
      if (marker != _Marker.italic || !_isPartOfDoubleStar(text, index)) {
        return index;
      }
      index = text.indexOf(marker.symbol, index + 2);
    }
    return null;
  }

  static bool _isPartOfDoubleStar(String text, int index) {
    if (text[index] != '*') return false;
    final before = index > 0 && text[index - 1] == '*';
    final after = index + 1 < text.length && text[index + 1] == '*';
    return before || after;
  }

  static void _append(List<MessageSegment> segments, MessageSegment segment) {
    if (segments.isNotEmpty && segments.last.hasSameStyle(segment)) {
      final last = segments.removeLast();
      segments.add(
        MessageSegment(
          last.text + segment.text,
          secret: last.secret,
          bold: last.bold,
          italic: last.italic,
          strike: last.strike,
        ),
      );
      return;
    }
    segments.add(segment);
  }
}
