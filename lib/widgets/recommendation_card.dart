import 'package:flutter/material.dart';

import '../models/book_recommendation.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    required this.recommendation,
    required this.isSaved,
    required this.onToggleBookmark,
    required this.onOpenLink,
    super.key,
  });

  final BookRecommendation recommendation;
  final bool isSaved;
  final VoidCallback onToggleBookmark;
  final Future<void> Function(String url) onOpenLink;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final borderColor = primary.withAlpha(31);
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: BorderSide(color: borderColor),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    recommendation.title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: onToggleBookmark,
                  icon: Icon(isSaved ? Icons.bookmark : Icons.bookmark_outline),
                  color: theme.colorScheme.primary,
                  tooltip: isSaved ? 'Remover dos favoritos' : 'Salvar nos favoritos',
                ),
              ],
            ),
            if (recommendation.description.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                recommendation.description,
                style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
              ),
            ],
            if (recommendation.reason.isNotEmpty) ...[
              const SizedBox(height: 14),
              _HighlightBlock(
                icon: Icons.lightbulb_outline,
                label: 'Por que ler',
                text: recommendation.reason,
              ),
            ],
            if (recommendation.classicLink.isNotEmpty) ...[
              const SizedBox(height: 14),
              _HighlightBlock(
                icon: Icons.menu_book_outlined,
                label: 'Conexão clássica',
                text: recommendation.classicLink,
              ),
            ],
            if (recommendation.amazonLink.isNotEmpty) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                onPressed: () => onOpenLink(recommendation.amazonLink),
                icon: const Icon(Icons.shopping_bag_outlined),
                label: const Text('Ver na Amazon'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _HighlightBlock extends StatelessWidget {
  const _HighlightBlock({
    required this.icon,
    required this.label,
    required this.text,
  });

  final IconData icon;
  final String label;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final background = primary.withAlpha(15);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primary),
              const SizedBox(width: 8),
              Text(
                label,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            text,
            style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}
