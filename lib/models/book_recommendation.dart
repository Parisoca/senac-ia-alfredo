import 'dart:convert';

import 'package:hive/hive.dart';

@HiveType(typeId: 2)
class BookRecommendation {
  BookRecommendation({
    String? id,
    required this.title,
    required this.description,
    required this.reason,
    required this.classicLink,
    required this.amazonLink,
    DateTime? savedAt,
  })  : id = id ?? _computeId(title, amazonLink),
        savedAt = savedAt ?? DateTime.now();

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String title;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String reason;

  @HiveField(4)
  final String classicLink;

  @HiveField(5)
  final String amazonLink;

  @HiveField(6)
  final DateTime savedAt;

  static String _computeId(String title, String link) {
    final base = '${title.trim().toLowerCase()}|${link.trim().toLowerCase()}';
    return base64Url.encode(utf8.encode(base));
  }

  factory BookRecommendation.fromJson(Map<String, dynamic> json) {
    return BookRecommendation(
      title: (json['title'] as String? ?? '').trim(),
      description: (json['description'] as String? ?? '').trim(),
      reason: (json['reason'] as String? ?? '').trim(),
      classicLink: (json['classic_link'] as String? ?? '').trim(),
      amazonLink: (json['amazon_link'] as String? ?? '').trim(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'reason': reason,
      'classic_link': classicLink,
      'amazon_link': amazonLink,
      'saved_at': savedAt.toIso8601String(),
    };
  }

  BookRecommendation copyWith({
    String? title,
    String? description,
    String? reason,
    String? classicLink,
    String? amazonLink,
    DateTime? savedAt,
  }) {
    final newTitle = title ?? this.title;
    final newLink = amazonLink ?? this.amazonLink;
    return BookRecommendation(
      id: _computeId(newTitle, newLink),
      title: newTitle,
      description: description ?? this.description,
      reason: reason ?? this.reason,
      classicLink: classicLink ?? this.classicLink,
      amazonLink: newLink,
      savedAt: savedAt ?? this.savedAt,
    );
  }
}

class BookRecommendationAdapter extends TypeAdapter<BookRecommendation> {
  @override
  final int typeId = 2;

  @override
  BookRecommendation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{};
    for (var i = 0; i < numOfFields; i++) {
      final key = reader.readByte();
      fields[key] = reader.read();
    }
    return BookRecommendation(
      id: fields[0] as String,
      title: fields[1] as String,
      description: fields[2] as String,
      reason: fields[3] as String,
      classicLink: fields[4] as String,
      amazonLink: fields[5] as String,
      savedAt: fields[6] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BookRecommendation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.reason)
      ..writeByte(4)
      ..write(obj.classicLink)
      ..writeByte(5)
      ..write(obj.amazonLink)
      ..writeByte(6)
      ..write(obj.savedAt);
  }
}
