import 'package:flutter/foundation.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/book_recommendation.dart';

class LocalStorageService {
  static const String bookmarksBoxName = 'book_recommendations';
  static bool _initialized = false;

  static Future<void> init() async {
    if (_initialized) return;
    await Hive.initFlutter();
    if (!Hive.isAdapterRegistered(BookRecommendationAdapter().typeId)) {
      Hive.registerAdapter(BookRecommendationAdapter());
    }
    await Hive.openBox<BookRecommendation>(bookmarksBoxName);
    _initialized = true;
  }

  static Box<BookRecommendation> _box() => Hive.box<BookRecommendation>(bookmarksBoxName);

  static List<BookRecommendation> getBookmarks() {
    final items = _box().values.toList(growable: false);
    items.sort((a, b) => b.savedAt.compareTo(a.savedAt));
    return items;
  }

  static Set<String> get bookmarkIds => _box().keys.cast<String>().toSet();

  static Future<void> save(BookRecommendation recommendation) async {
    final normalized = recommendation.copyWith(savedAt: DateTime.now());
    await _box().put(normalized.id, normalized);
  }

  static Future<void> remove(String id) async {
    await _box().delete(id);
  }

  static bool isSaved(String id) => _box().containsKey(id);

  static Future<void> clearAll() async {
    await _box().clear();
  }

  static ValueListenable<Box<BookRecommendation>> listenable({List<dynamic>? keys}) {
    return _box().listenable(keys: keys);
  }
}
