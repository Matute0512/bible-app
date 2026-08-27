/// A single numbered verse of a Bible chapter.
class Verse {
  const Verse({required this.number, required this.text});

  /// 1-based position of the verse within its chapter.
  final int number;

  /// Plain-text content of the verse, free of markup.
  final String text;

  /// Parses a verse from one item of the `*.simple.json` payload.
  factory Verse.fromJson(Map<String, dynamic> json) => Verse(
        number: json['number'] as int,
        text: json['text'] as String,
      );
}
