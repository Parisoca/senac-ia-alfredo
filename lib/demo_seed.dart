import 'config.dart';
import 'models/book_recommendation.dart';

/// Builds deterministic demo recommendations for offline previews.
List<BookRecommendation> demoSeedRecommendations() {
  return kDemoBookRecommendations
      .map(BookRecommendation.fromJson)
      .toList(growable: false);
}
