/// Configurações centrais do Alfredo.
library;

import 'package:flutter/foundation.dart';

const String kAppDisplayName = 'Alfredo';
const String kAppDomain = 'dev.connect8';

const String kFlowiseEndpoint =
	'https://flowise.parisihub.com.br/api/v1/prediction/2ece0a30-7336-4253-8646-fa016eff37f1';

bool kDemoSafeMode = false;
final ValueNotifier<bool> kDemoSafeModeNotifier = ValueNotifier<bool>(kDemoSafeMode);

const String kDefaultAssistantGreeting =
	'Olá, eu sou o Alfredo. Conte um pouco sobre o que você gosta de ler e eu preparo sugestões especiais para você.';

const List<Map<String, String>> kDemoBookRecommendations = [
	{
		'title': 'A livraria mágica de Paris',
		'description':
			'Um romance acolhedor que celebra pequenas livrarias, novas amizades e o poder transformador da leitura.',
		'reason':
			'Sugiro este título para leitores que buscam histórias calorosas e personagens que redescobrem a vida através dos livros.',
		'classic_link':
			'Lembra a atmosfera de “A livraria mágica de Paris”, que homenageia clássicos franceses e mostra como as histórias nos conectam.',
		'amazon_link': 'https://www.amazon.com.br/dp/B09ZP78H2D'
	},
	{
		'title': 'O clube do livro dos homens',
		'description':
			'Comédia romântica leve sobre um grupo de amigos que usa romances para entender melhor seus relacionamentos.',
		'reason':
			'Recomendado para quem deseja algo espirituoso, com diálogos rápidos e um olhar divertido sobre amizade e amor.',
		'classic_link':
			'É um contraponto contemporâneo a “Orgulho e Preconceito”, brincando com as convenções dos romances clássicos.',
		'amazon_link': 'https://www.amazon.com.br/dp/B08M3N7V2M'
	},
];
