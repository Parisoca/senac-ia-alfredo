import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../config.dart';
import '../models/book_recommendation.dart';
import 'logger.dart';

class RecommendationResult {
  const RecommendationResult({
    this.recommendations = const <BookRecommendation>[],
    this.fallbackMessage,
  });

  final List<BookRecommendation> recommendations;
  final String? fallbackMessage;

  bool get hasRecommendations => recommendations.isNotEmpty;
}

class RecommendationService {
  RecommendationService({http.Client? client}) : _client = client ?? http.Client();

  static const Duration defaultTimeout = Duration(seconds: 30);

  final http.Client _client;
  String? _sessionId;

  Future<RecommendationResult> ask(String prompt) async {
    if (kDemoSafeMode) {
      final demo = kDemoBookRecommendations
          .map((entry) => BookRecommendation.fromJson(entry))
          .toList(growable: false);
      logInfo('Demo mode: retornando ${demo.length} recomendações prontas', context: 'RecommendationService');
      return RecommendationResult(
        recommendations: demo,
        fallbackMessage: 'Sugestões geradas em modo demonstração.',
      );
    }

    try {
      final payload = <String, dynamic>{'question': prompt};
      final session = _sessionId?.trim();
      if (session != null && session.isNotEmpty) {
        payload['overrideConfig'] = {'sessionId': session};
        payload['chatId'] = session;
      }

      final response = await _client
          .post(
            Uri.parse(kFlowiseEndpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(defaultTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        logError(
          'Flowise retornou ${response.statusCode}: ${response.body}',
          context: 'RecommendationService',
        );
        throw Exception('Não foi possível obter recomendações (${response.statusCode}).');
      }

      final body = response.body.trim();
      final sessionFromResponse = _extractSessionIdentifier(body);
      if (sessionFromResponse != null) {
        _sessionId = sessionFromResponse;
      }
      final parsed = _tryParseRecommendations(body);
      final readableMessage = _extractReadableMessage(body);
      if (parsed != null && parsed.isNotEmpty) {
        logInfo('Recomendações parseadas: ${parsed.length}', context: 'RecommendationService');
        return RecommendationResult(recommendations: parsed);
      }

      if (parsed != null && parsed.isEmpty) {
        logWarn('Resposta JSON vazia; exibindo mensagem textual', context: 'RecommendationService');
      } else {
        logWarn('Resposta não estruturada; exibindo texto cru', context: 'RecommendationService');
      }
      return RecommendationResult(fallbackMessage: readableMessage);
    } on TimeoutException {
      logError('Tempo excedido na solicitação ao Flowise', context: 'RecommendationService');
      throw Exception('Sem resposta do servidor. Tente novamente em instantes.');
    } catch (e) {
      if (e is Exception) rethrow;
      throw Exception('Falha inesperada ao falar com o servidor.');
    }
  }

  void resetSession() {
    _sessionId = null;
  }

  List<BookRecommendation>? _tryParseRecommendations(String raw, {Set<String>? visited}) {
    final sanitized = _sanitizeJsonBlock(raw);
    final trackers = visited ?? <String>{};
    if (!trackers.add(sanitized)) {
      return null;
    }
    final decoded = _decodeLenientJson(sanitized);
    return _extractRecommendations(decoded, trackers);
  }

  List<BookRecommendation>? _extractRecommendations(dynamic decoded, Set<String> visited) {
    if (decoded is Map<String, dynamic>) {
      final direct = _parseRecommendationContainer(decoded, visited);
      if (direct != null && direct.isNotEmpty) {
        return direct;
      }

      final keysToInspect = [
        'recomendations',
        'recommendations',
        'books',
        'items',
        'results',
        'result',
        'payload',
        'data',
        'output',
        'response',
        'message',
        'text',
        'finalResult',
        'content',
      ];
      for (final key in keysToInspect) {
        if (!decoded.containsKey(key)) continue;
        final nested = _extractRecommendations(decoded[key], visited);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    } else if (decoded is List) {
      final direct = decoded
          .map(_mapToRecommendation)
          .whereType<BookRecommendation>()
          .toList(growable: false);
      if (direct.isNotEmpty) {
        return direct;
      }
      for (final element in decoded) {
        final nested = _extractRecommendations(element, visited);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    } else if (decoded is String) {
      final trimmed = decoded.trim();
      if (trimmed.startsWith('{') || trimmed.startsWith('[') || trimmed.startsWith('```')) {
        return _tryParseRecommendations(trimmed, visited: visited);
      }
    }
    return null;
  }

  List<BookRecommendation>? _parseRecommendationContainer(
    Map<String, dynamic> map,
    Set<String> visited,
  ) {
    final single = _mapToRecommendation(map);
    if (single != null && single.title.isNotEmpty) {
      return [single];
    }

    final candidateKeys = ['recomendations', 'recommendations', 'books', 'items'];
    for (final key in candidateKeys) {
      if (!map.containsKey(key)) continue;
      final recs = _convertToRecommendationList(map[key], visited);
      if (recs != null && recs.isNotEmpty) {
        return recs;
      }
    }
    return null;
  }

  List<BookRecommendation>? _convertToRecommendationList(dynamic source, Set<String> visited) {
    if (source is List) {
      final recs = source
          .map(_mapToRecommendation)
          .whereType<BookRecommendation>()
          .toList(growable: false);
      if (recs.isNotEmpty) {
        return recs;
      }
      for (final element in source) {
        final nested = _extractRecommendations(element, visited);
        if (nested != null && nested.isNotEmpty) {
          return nested;
        }
      }
    } else if (source is Map<String, dynamic>) {
      return _parseRecommendationContainer(source, visited);
    } else if (source is String) {
      return _tryParseRecommendations(source, visited: visited);
    }
    return null;
  }

  BookRecommendation? _mapToRecommendation(dynamic value) {
    if (value is Map<String, dynamic>) {
      if (_looksLikeRecommendationMap(value)) {
        final rec = BookRecommendation.fromJson(value);
        if (rec.title.isNotEmpty || rec.description.isNotEmpty) {
          return rec;
        }
      }
    }
    return null;
  }

  bool _looksLikeRecommendationMap(Map<String, dynamic> map) {
    const signalKeys = ['title', 'description', 'reason', 'classic_link', 'amazon_link'];
    var hits = 0;
    for (final key in signalKeys) {
      final value = map[key];
      if (value is String && value.trim().isNotEmpty) {
        hits++;
      }
    }
    return hits >= 2;
  }

  String _sanitizeJsonBlock(String input) {
    var text = input.trim();
    if (text.startsWith('```')) {
      final firstBreak = text.indexOf('\n');
      if (firstBreak != -1) {
        text = text.substring(firstBreak + 1);
      }
      final closingFence = text.lastIndexOf('```');
      if (closingFence != -1) {
        text = text.substring(0, closingFence);
      }
      text = text.trim();
    }
    return text;
  }

  dynamic _decodeLenientJson(String text) {
    try {
      return jsonDecode(text);
    } catch (_) {
      final start = text.indexOf('{');
      final end = text.lastIndexOf('}');
      if (start != -1 && end != -1 && end > start) {
        final snippet = text.substring(start, end + 1);
        try {
          return jsonDecode(snippet);
        } catch (_) {
          return null;
        }
      }
      return null;
    }
  }

  String _extractReadableMessage(String raw) {
    final sanitized = _sanitizeJsonBlock(raw);
    final decoded = _decodeLenientJson(sanitized);
    if (decoded is Map<String, dynamic>) {
      final map = decoded;
      final textKeys = ['finalResult', 'text', 'message', 'answer', 'response'];
      for (final key in textKeys) {
        final value = map[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return raw;
  }

  String? _extractSessionIdentifier(String raw) {
    final sanitized = _sanitizeJsonBlock(raw);
    final decoded = _decodeLenientJson(sanitized);
    if (decoded is Map<String, dynamic>) {
      final keys = ['sessionId', 'chatId'];
      for (final key in keys) {
        final value = decoded[key];
        if (value is String && value.trim().isNotEmpty) {
          return value.trim();
        }
      }
    }
    return null;
  }
}
