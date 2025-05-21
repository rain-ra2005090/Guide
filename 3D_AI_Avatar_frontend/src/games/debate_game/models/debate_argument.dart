class DebateArgument {
  final String text;
  final double score;
  final List<String> strongWords;
  final String feedback;

  DebateArgument({
    required this.text,
    this.score = 0.0,
    this.strongWords = const [],
    this.feedback = '',
  });

  factory DebateArgument.fromJson(Map<String, dynamic> json) {
    return DebateArgument(
      text: json['text'] ?? '',
      score: json['score']?.toDouble() ?? 0.0,
      strongWords: List<String>.from(json['strongWords'] ?? []),
      feedback: json['feedback'] ?? '',
    );
  }
}
