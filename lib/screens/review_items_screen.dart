import 'package:flutter/material.dart';

class ReviewItemsScreen extends StatelessWidget {
  const ReviewItemsScreen({super.key, required this.initialItems});

  final List<Map<String, dynamic>> initialItems;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Revisão')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.edit_off, size: 48),
              const SizedBox(height: 16),
              Text(
                'A revisão manual de itens foi descontinuada no Alfredo.',
                style: Theme.of(context).textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Converse com o assistente para receber recomendações de leitura e organize seus favoritos.',
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/* Legado: implementação original removida em favor da experiência Alfredo. */
