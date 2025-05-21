class DebateTopic {
  final String topic;
  final String description;

  DebateTopic({
    required this.topic,
    required this.description,
  });

  factory DebateTopic.fromJson(Map<String, dynamic> json) {
    return DebateTopic(
      topic: json['topic'] ?? '',
      description: json['description'] ?? '',
    );
  }
}
