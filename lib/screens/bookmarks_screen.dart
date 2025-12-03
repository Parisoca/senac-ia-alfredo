import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../models/book_recommendation.dart';
import '../services/local_storage.dart';
import '../widgets/recommendation_card.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: LocalStorageService.listenable(),
      builder: (context, _, __) {
        final bookmarks = LocalStorageService.getBookmarks();
        if (bookmarks.isEmpty) {
          return const _EmptyBookmarks();
        }
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Suas recomendações salvas',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: ListView.separated(
                  itemCount: bookmarks.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    final item = bookmarks[index];
                    return RecommendationCard(
                      recommendation: item,
                      isSaved: true,
                      onToggleBookmark: () => _remove(item),
                      onOpenLink: (url) => _openLink(context, url),
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _remove(BookRecommendation item) async {
    await LocalStorageService.remove(item.id);
  }

  Future<void> _openLink(BuildContext context, String url) async {
    final messenger = ScaffoldMessenger.of(context);
    final trimmed = url.trim();
    if (trimmed.isEmpty) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Link não informado.')));
      return;
    }
    Uri? uri;
    try {
      uri = Uri.parse(trimmed);
    } catch (_) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Link inválido.')));
      return;
    }
    if (!uri.hasScheme) {
      uri = uri.replace(scheme: 'https');
    }
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      messenger
        ..hideCurrentSnackBar()
        ..showSnackBar(const SnackBar(content: Text('Não consegui abrir o link.')));
    }
  }
}

class _EmptyBookmarks extends StatelessWidget {
  const _EmptyBookmarks();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(
              color: Color(0x16000000),
              blurRadius: 18,
              offset: Offset(0, 6),
            ),
          ],
        ),
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.bookmark_add_outlined, size: 48, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'Nada salvo ainda',
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Toda vez que uma recomendação chamar sua atenção, toque no ícone de marcador para mantê-la aqui.',
              style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
