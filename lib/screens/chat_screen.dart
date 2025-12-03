import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../config.dart';
import '../models/book_recommendation.dart';
import '../services/local_storage.dart';
import '../services/logger.dart';
import '../services/recommendation_service.dart';
import '../widgets/recommendation_card.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class ChatEntry {
  ChatEntry.user(this.text)
      : isUser = true,
        recommendations = const [];

  ChatEntry.assistant({this.text, this.recommendations = const []})
      : isUser = false;

  final bool isUser;
  final String? text;
  final List<BookRecommendation> recommendations;
}

class _ChatScreenState extends State<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _service = RecommendationService();
  final List<ChatEntry> _entries = [
    ChatEntry.assistant(text: kDefaultAssistantGreeting),
  ];

  bool _isSending = false;

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final prompt = _controller.text.trim();
    if (prompt.isEmpty || _isSending) return;

    setState(() {
      _entries.add(ChatEntry.user(prompt));
      _controller.clear();
      _isSending = true;
    });
    _scrollToBottom();

    try {
      final result = await _service.ask(prompt);
      final text = result.hasRecommendations
          ? 'Encontrei algumas leituras para você:'
          : (result.fallbackMessage?.trim().isNotEmpty == true
              ? result.fallbackMessage!.trim()
              : 'Ainda não encontrei recomendações. Pode reformular o pedido?');
      setState(() {
        _entries.add(ChatEntry.assistant(
          text: text,
          recommendations: result.recommendations,
        ));
        _isSending = false;
      });
      _scrollToBottom();
    } catch (e) {
      logError('Falha ao consultar recomendações: $e', context: 'ChatScreen');
      if (!mounted) return;
      setState(() {
        _entries.add(
          ChatEntry.assistant(
            text: 'Encontrei um problema ao falar com o servidor. Tente novamente em instantes.',
          ),
        );
        _isSending = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _toggleBookmark(BookRecommendation recommendation, bool isSaved) async {
    try {
      if (isSaved) {
        await LocalStorageService.remove(recommendation.id);
        _showSnack('Removido dos favoritos');
      } else {
        await LocalStorageService.save(recommendation);
        _showSnack('Salvo nos favoritos');
      }
    } catch (e) {
      logError('Erro ao alternar favorito: $e', context: 'ChatScreen');
      _showSnack('Não foi possível atualizar o favorito.');
    }
  }

  Future<void> _openLink(String url) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      _showSnack('Link indisponível para este livro.');
      return;
    }
    Uri? uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (_) {
      _showSnack('Link inválido informado pela recomendação.');
      return;
    }
    if (!uri.hasScheme) {
      uri = uri.replace(scheme: 'https');
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      _showSnack('Não consegui abrir o link informado.');
    }
  }

  Future<void> _confirmReset() async {
    if (_isSending) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Reiniciar conversa'),
          content: const Text('Deseja limpar o histórico desta conversa? Seus favoritos permanecerão salvos.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Reiniciar'),
            ),
          ],
        );
      },
    );
    if (confirmed == true) {
      _resetConversation();
    }
  }

  void _resetConversation() {
    _service.resetSession();
    setState(() {
      _entries
        ..clear()
        ..add(ChatEntry.assistant(text: kDefaultAssistantGreeting));
      _controller.clear();
      _isSending = false;
    });
    _scrollToBottom();
    _showSnack('Conversa reiniciada.');
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LocalStorageService.listenable(),
      builder: (context, _, __) {
        final savedIds = LocalStorageService.bookmarkIds;
        return SafeArea(
          top: false,
          bottom: true,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                child: Align(
                  alignment: Alignment.centerRight,
                  child: OutlinedButton.icon(
                    onPressed: _isSending ? null : _confirmReset,
                    icon: const Icon(Icons.restart_alt),
                    label: const Text('Reiniciar conversa'),
                  ),
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                  itemCount: _entries.length + (_isSending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (_isSending && index == _entries.length) {
                      return _AssistantBubble(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                            SizedBox(width: 12),
                            Text('Buscando sugestões...'),
                          ],
                        ),
                      );
                    }

                    final entry = _entries[index];
                    if (entry.isUser) {
                      return _UserBubble(text: entry.text ?? '');
                    }

                    return _AssistantReply(
                      entry: entry,
                      savedIds: savedIds,
                      onToggleBookmark: _toggleBookmark,
                      onOpenLink: _openLink,
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              _Composer(
                controller: _controller,
                onSend: _sendMessage,
                isSending: _isSending,
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.onSend,
    required this.isSending,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isSending;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: const [
          BoxShadow(
            color: Color(0x1A000000),
            blurRadius: 12,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              minLines: 1,
              maxLines: 4,
              onSubmitted: (_) => onSend(),
              style: const TextStyle(fontSize: 18, height: 1.45),
              decoration: const InputDecoration.collapsed(
                hintText: 'Conte o que procura em sua próxima leitura...',
                hintStyle: TextStyle(fontSize: 18, height: 1.45),
              ),
            ),
          ),
          const SizedBox(width: 12),
          isSending
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(strokeWidth: 2.4),
                )
              : IconButton.filled(
                  onPressed: onSend,
                  style: IconButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                  ),
                  icon: const Icon(Icons.send_rounded),
                ),
        ],
      ),
    );
  }
}

class _UserBubble extends StatelessWidget {
  const _UserBubble({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 18, height: 1.5),
        ),
      ),
    );
  }
}

class _AssistantBubble extends StatelessWidget {
  const _AssistantBubble({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(14),
        constraints: const BoxConstraints(maxWidth: 420),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
          boxShadow: const [
            BoxShadow(
              color: Color(0x11000000),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: child,
      ),
    );
  }
}

class _AssistantReply extends StatelessWidget {
  const _AssistantReply({
    required this.entry,
    required this.savedIds,
    required this.onToggleBookmark,
    required this.onOpenLink,
  });

  final ChatEntry entry;
  final Set<String> savedIds;
  final Future<void> Function(BookRecommendation, bool) onToggleBookmark;
  final Future<void> Function(String) onOpenLink;

  @override
  Widget build(BuildContext context) {
    final widgets = <Widget>[];
    if ((entry.text ?? '').isNotEmpty) {
      widgets.add(
        _AssistantBubble(
          child: Text(
            entry.text!.trim(),
            style: const TextStyle(fontSize: 18, height: 1.55),
          ),
        ),
      );
    }

    if (entry.recommendations.isNotEmpty) {
      widgets.add(
        const SizedBox(height: 8),
      );
      widgets.addAll(
        entry.recommendations.map(
          (rec) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: RecommendationCard(
              recommendation: rec,
              isSaved: savedIds.contains(rec.id),
              onToggleBookmark: () => onToggleBookmark(rec, savedIds.contains(rec.id)),
              onOpenLink: onOpenLink,
            ),
          ),
        ),
      );
    }

    if (widgets.isEmpty) {
      return _AssistantBubble(
        child: const Text(
          'Estou aqui para ajudar com novas leituras.',
          style: TextStyle(fontSize: 18, height: 1.55),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widgets,
    );
  }
}
