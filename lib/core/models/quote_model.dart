import 'dart:convert';

class QuoteModel {
  final String id;
  final String quote;
  final String author;
  final String category;
  final String explanation;
  final DateTime date;
  final bool hasRegenerated;
  final bool isCached;

  const QuoteModel({
    required this.id,
    required this.quote,
    required this.author,
    required this.category,
    required this.explanation,
    required this.date,
    this.hasRegenerated = false,
    this.isCached = false,
  });

  factory QuoteModel.fromJson(Map<String, dynamic> json) {
    return QuoteModel(
      id: json['id'] ?? json['_id'] ?? '',
      quote: json['quote'] ?? '',
      author: json['author'] ?? 'Unknown',
      category: json['category'] ?? json['topic'] ?? 'General',
      explanation: json['explanation'] ?? '',
      date: json['date'] != null ? DateTime.parse(json['date']) : DateTime.now(),
      hasRegenerated: json['hasRegenerated'] ?? false,
      isCached: json['isCached'] ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quote': quote,
        'author': author,
        'category': category,
        'explanation': explanation,
        'date': date.toIso8601String(),
        'hasRegenerated': hasRegenerated,
        'isCached': isCached,
      };

  String toJsonString() => jsonEncode(toJson());

  static QuoteModel fromJsonString(String str) =>
      QuoteModel.fromJson(jsonDecode(str));

  QuoteModel copyWith({
    String? id,
    String? quote,
    String? author,
    String? category,
    String? explanation,
    DateTime? date,
    bool? hasRegenerated,
    bool? isCached,
  }) {
    return QuoteModel(
      id: id ?? this.id,
      quote: quote ?? this.quote,
      author: author ?? this.author,
      category: category ?? this.category,
      explanation: explanation ?? this.explanation,
      date: date ?? this.date,
      hasRegenerated: hasRegenerated ?? this.hasRegenerated,
      isCached: isCached ?? this.isCached,
    );
  }
}
