import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
	const HomeScreen({super.key});

	@override
	Widget build(BuildContext context) {
		return const Scaffold(
			body: Center(
				child: Padding(
					padding: EdgeInsets.all(24),
					child: Text(
						'Este módulo foi substituído pelo Alfredo. Utilize a nova experiência na tela principal.',
						textAlign: TextAlign.center,
					),
				),
			),
		);
	}
}

/* Arquivo descontinuado: a tela inicial foi substituída pelo shell de navegação do Alfredo.

import 'package:flutter/material.dart';

import '../models/grocery_item.dart';
import '../services/local_storage.dart';
import '../config.dart';
import '../services/logger.dart';
import '../demo_seed.dart';
import 'capture_screen.dart';
import 'items_screen.dart';
import 'logs_screen.dart';

... conteúdo original mantido para referência ...

*/
