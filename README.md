# Alfredo

Alfredo é um concierge literário que mora direto no dispositivo. Ele conversa em português, entende suas referências e responde com sugestões de leitura que já chegam formatadas em cartões. O foco do projeto é mostrar como um agente conversacional pode guiar o usuário em escolhas culturais — sem depender de um backend complexo.

## O que o app oferece
- **Conversa acolhedora** – A tela principal reproduz um bate-papo com um bibliotecário virtual. A saudação inicial apresenta o tom do personagem, e cada nova pergunta flui na mesma janela, mantendo contexto a partir da sessão ativa com o agente.
- **Sugestões ricas em contexto** – Quando o LLM retorna um bloco JSON com título, descrição, motivo, referência clássica e link, Alfredo transforma esse retorno em cartões elegantes. Cada card já traz botão para abrir o link (Amazon por padrão) no navegador ou app externo.
- **Favoritos offline** – Um toque no ícone de marcador salva a recomendação em uma estante local. Esses itens ficam disponíveis mesmo sem internet e podem ser revisitados na aba “Favoritos”.
- **Reinício rápido** – Caso queira começar uma nova conversa, basta usar o botão “Reiniciar conversa”. Ele limpa o chat e reinicia a sessão no agente, mas mantém todos os favoritos intactos.
- **Modo demonstração** – Configure `kDemoSafeMode = true` em `lib/config.dart` antes de compilar para testar a interface com respostas determinísticas pré-carregadas, sem depender do serviço remoto.

## Como a experiência funciona
1. Você escreve em linguagem natural o que procura — “gosto de fantasia com humor ácido”, por exemplo.
2. O app envia a mensagem para um fluxo Flowise configurado pela equipe. O payload inclui uma `sessionId` reutilizada, permitindo que o agente se lembre do contexto anterior.
3. O Flowise orquestra o modelo (Azure OpenAI, OpenAI ou outro provedor compatível) e devolve texto ou JSON estruturado. Quando há JSON, Alfredo filtra, sanitiza e converte em objetos de recomendação; quando não há, mostra a resposta textual mesmo assim.
4. Você pode salvar, abrir links ou refinar o pedido – o histórico permanece visível até que seja reiniciado manualmente.

## Bastidores principais
- **Flutter (Android + Web)**: interface responsiva, Material 3 e animações leves.
- **Flowise Agent**: backend low-code que faz a ponte com o LLM, cuida do prompt e define o formato de resposta.
- **Armazenamento local com Hive**: mantém favoritos e possibilita o modo demo sem internet.
- **url_launcher**: abre os links recomendados fora do app.

## Começando
1. Configure o endpoint do Flowise em `lib/config.dart` (`kFlowiseEndpoint`).
2. Rode `flutter pub get` para baixar as dependências.
3. Execute no alvo desejado:
   - Android: `flutter run -d android`
   - Web: `flutter run -d chrome`
4. Ative o modo demo se quiser validar rapidamente os fluxos visuais.

## Para apresentar
- Demonstre a conversa em sequência: saudação → interesses do usuário → cartão de recomendação.
- Salve pelo menos uma sugestão e migre para a aba “Favoritos” para provar que os dados ficam guardados localmente.
- Reinicie o chat diante do público para evidenciar como o agente reseta o contexto sem perder o acervo.

---
Projeto mantido pela Connect8 como vitrine de experiências conversacionais com foco em cultura e entretenimento. Ajuste o agente, as amostras de demo e a identidade visual conforme o uso desejado.
