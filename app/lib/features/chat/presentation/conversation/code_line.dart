enum CodeTokenKind {
  plain,
  keyword,
  function,
  string,
  escape,
  number,
  comment,
  todo,
}

class CodeToken {
  const CodeToken(
    this.text,
    this.kind, {
    this.secret = false,
    this.bold = false,
    this.italic = false,
    this.strike = false,
  });

  final String text;
  final CodeTokenKind kind;
  final bool secret;
  final bool bold;
  final bool italic;
  final bool strike;
}

class CodeLine {
  const CodeLine(
    this.tokens, {
    this.messageId,
    this.changed = false,
    this.runnable = false,
  });

  static const blank = CodeLine([]);

  final List<CodeToken> tokens;
  final String? messageId;
  final bool changed;
  final bool runnable;

  int get indent {
    final text = this.text;
    var count = 0;
    while (count < text.length && text[count] == ' ') {
      count++;
    }
    return count == text.length ? 0 : count;
  }

  String get text => tokens.map((token) => token.text).join();
}
