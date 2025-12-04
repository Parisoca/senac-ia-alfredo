import 'package:flutter/material.dart';
import '../models/book_recommendation.dart';

class RecommendationCard extends StatelessWidget {
  const RecommendationCard({
    super.key,
    required this.recommendation,
    required this.isSaved,
    required this.onToggleBookmark,
    required this.onOpenLink,
  });

  final BookRecommendation recommendation;
  final bool isSaved;
  final VoidCallback onToggleBookmark;
  final Function(String) onOpenLink;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 1. ÁREA DA CAPA E TÍTULO
          Container(
            color: Colors.grey.shade100,
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Capa
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    recommendation.coverUrl,
                    width: 100,
                    height: 150,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 100, 
                      height: 150, 
                      color: Colors.grey.shade300,
                      child: const Icon(Icons.book, size: 40, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                // Título e Autor
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation.title,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        recommendation.author,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey.shade700,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Botão de Favorito pequeno
                      InkWell(
                        onTap: onToggleBookmark,
                        child: Row(
                          children: [
                            Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_border,
                              color: isSaved ? Colors.orange : Colors.grey,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              isSaved ? "Salvo" : "Salvar",
                              style: TextStyle(
                                color: isSaved ? Colors.orange : Colors.grey.shade600,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),

          // 2. MOTIVAÇÃO DO ALFREDO
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Por que o Alfredo recomenda:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.deepPurple,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  recommendation.reason,
                  style: const TextStyle(fontSize: 16, height: 1.4),
                ),
                const SizedBox(height: 16),
                
                // Botão de Ação Principal
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: () => onOpenLink(recommendation.amazonLink),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE47911), // Cor Amazon
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.shopping_cart_outlined),
                    label: const Text(
                      "VER NA AMAZON",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}