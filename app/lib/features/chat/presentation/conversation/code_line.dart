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
  const CodeLine(this.tokens, {this.messageId, this.changed = false});

  static const blank = CodeLine([]);

  final List<CodeToken> tokens;
  final String? messageId;
  final bool changed;

  String get text => tokens.map((token) => token.text).join();
}
