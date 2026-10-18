class MessageSegment {
  const MessageSegment(
    this.text, {
    this.secret = false,
    this.bold = false,
    this.italic = false,
    this.strike = false,
  });

  final String text;
  final bool secret;
  final bool bold;
  final bool italic;
  final bool strike;

  bool hasSameStyle(MessageSegment other) =>
      secret == other.secret &&
      bold == other.bold &&
      italic == other.italic &&
      strike == other.strike;

  @override
  bool operator ==(Object other) =>
      other is MessageSegment && other.text == text && hasSameStyle(other);

  @override
  int get hashCode => Object.hash(text, secret, bold, italic, strike);

  @override
  String toString() {
    final styles = [
      if (secret) 'secret',
      if (bold) 'bold',
      if (italic) 'italic',
      if (strike) 'strike',
    ];
    return 'MessageSegment("$text"${styles.isEmpty ? '' : ', ${styles.join(', ')}'})';
  }
}
