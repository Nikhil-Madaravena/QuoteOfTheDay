class PreferenceEntity {
  final String goal;
  final String tone;
  final List<String> favoriteAuthors;
  final String quoteLength;
  final List<String> topics;
  final String language;
  final String notificationTime;

  PreferenceEntity({
    required this.goal,
    required this.tone,
    required this.favoriteAuthors,
    required this.quoteLength,
    required this.topics,
    required this.language,
    required this.notificationTime,
  });

  factory PreferenceEntity.fromJson(Map<String, dynamic> json) {
    return PreferenceEntity(
      goal: json['goal'] ?? '',
      tone: json['tone'] ?? '',
      favoriteAuthors: List<String>.from(json['favoriteAuthors'] ?? []),
      quoteLength: json['quoteLength'] ?? 'any',
      topics: List<String>.from(json['topics'] ?? []),
      language: json['language'] ?? 'en',
      notificationTime: json['notificationTime'] ?? '08:00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'goal': goal,
      'tone': tone,
      'favoriteAuthors': favoriteAuthors,
      'quoteLength': quoteLength,
      'topics': topics,
      'language': language,
      'notificationTime': notificationTime,
    };
  }
}
