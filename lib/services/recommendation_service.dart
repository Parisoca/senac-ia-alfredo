import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config.dart'; // Certifique-se que kFlowiseEndpoint está aqui
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

  static const Duration defaultTimeout = Duration(seconds: 45); // Aumentei um pouco para IA
  final http.Client _client;
  
  // Mantemos o sessionId se o Flowise retornar, para manter o contexto da conversa
  String? _sessionId;

  Future<RecommendationResult> ask(String prompt) async {
    try {
      final payload = <String, dynamic>{'question': prompt};
      
      if (_sessionId != null) {
        payload['overrideConfig'] = {'sessionId': _sessionId};
        // Alguns setups do Flowise usam 'chatId', outros 'sessionId' no body
        payload['chatId'] = _sessionId; 
      }

      logInfo('Enviando pergunta: $prompt', context: 'RecommendationService');

      final response = await _client
          .post(
            Uri.parse(kFlowiseEndpoint),
            headers: const {'Content-Type': 'application/json'},
            body: jsonEncode(payload),
          )
          .timeout(defaultTimeout);

      if (response.statusCode != 200) {
        throw Exception('Erro ${response.statusCode}: ${response.body}');
      }

      final jsonResponse = jsonDecode(response.body);
      
      // Capturar ID da sessão se vier na resposta para continuar o chat
      if (jsonResponse['chatId'] != null) {
        _sessionId = jsonResponse['chatId'];
      } else if (jsonResponse['sessionId'] != null) {
        _sessionId = jsonResponse['sessionId'];
      }

      // O Flowise devolve a resposta principal dentro de "text"
      final String botText = jsonResponse['text'] ?? '';

      // TENTATIVA DE PARSING: É um JSON de Livro ou Texto normal?
      final detectedBook = _tryParseBook(botText);

      if (detectedBook != null) {
        // SUCCESSO: É um livro! Retornamos a recomendação e ZERO texto de fallback
        logInfo('Livro detectado: ${detectedBook.title}', context: 'RecommendationService');
        return RecommendationResult(recommendations: [detectedBook]);
      } else {
        // É apenas conversa
        logInfo('Resposta textual recebida', context: 'RecommendationService');
        return RecommendationResult(fallbackMessage: botText);
      }

    } catch (e) {
      logError('Erro na requisição: $e', context: 'RecommendationService');
      throw Exception('Não foi possível conectar ao Alfredo.');
    }
  }

  void resetSession() {
    _sessionId = null;
  }

  // Tenta extrair um JSON limpo de dentro do texto (caso venha com ```json ... ```)
  BookRecommendation? _tryParseBook(String text) {
    try {
      String cleanText = text.trim();
      
      // Remove blocos de código markdown se existirem
      if (cleanText.contains('```')) {
        final start = cleanText.indexOf('{');
        final end = cleanText.lastIndexOf('}');
        if (start != -1 && end != -1) {
          cleanText = cleanText.substring(start, end + 1);
        }
      }

      final decoded = jsonDecode(cleanText);
      
      // Validação mínima para garantir que é o nosso JSON de livro
      if (decoded is Map<String, dynamic> && decoded.containsKey('title') && decoded.containsKey('isbn')) {
        return BookRecommendation.fromJson(decoded);
      }
    } catch (e) {
      // Se falhar o jsonDecode, é porque é texto normal
      return null;
    }
    return null;
  }
}