import 'package:flutter/material.dart';

class ItemsScreen extends StatelessWidget {
  const ItemsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'A lista de itens foi substituída pelos favoritos do Alfredo.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}

/* Legado: implementação original removida em favor da experiência Alfredo. */
