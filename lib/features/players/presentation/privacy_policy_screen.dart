import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:go_router/go_router.dart';
import 'package:tennis_tournament/l10n/app_localizations.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  static const _content = '''
## 1. Informações que Coletamos

Coletamos as seguintes informações para fornecer e melhorar nosso serviço:

- **Dados de conta:** nome, endereço de e-mail e foto de perfil fornecidos no cadastro.
- **Dados de uso:** torneios criados ou participados, resultados de partidas, estatísticas de jogo e preferências do aplicativo.
- **Tokens de notificação:** identificadores de dispositivo usados exclusivamente para enviar notificações sobre suas partidas.
- **Dados de assinatura:** status do plano (gratuito ou premium), sem armazenar dados de pagamento — processados pelo Google Play ou App Store.
- **Dados de análise:** eventos de uso anônimos via Firebase Analytics para melhorar a experiência do aplicativo.

## 2. Como Usamos as Informações

Utilizamos as informações coletadas para:

- Criar e gerenciar sua conta e perfil de jogador.
- Exibir chaves, resultados e agendas de torneios.
- Enviar notificações sobre partidas, resultados e atualizações de status.
- Personalizar a experiência com base nas suas preferências.
- Analisar o uso do aplicativo e corrigir problemas técnicos.
- Cumprir obrigações legais quando necessário.

## 3. Compartilhamento de Informações

Não vendemos nem compartilhamos seus dados pessoais com terceiros para fins comerciais. Seus dados podem ser compartilhados apenas nas seguintes situações:

- **Outros participantes:** nome e foto de perfil são visíveis a outros usuários do torneio em que você participa.
- **Provedores de serviço:** utilizamos Google Firebase (Firestore, Authentication, Storage, Analytics, Messaging) como infraestrutura segura.
- **Obrigação legal:** quando exigido por lei ou ordem judicial.

## 4. Armazenamento e Segurança

Seus dados são armazenados no Google Firebase com criptografia em trânsito (HTTPS/TLS) e em repouso. Aplicamos regras de segurança no Firestore para garantir que cada usuário acesse apenas os dados aos quais tem permissão.

## 5. Retenção de Dados

Mantemos seus dados enquanto sua conta estiver ativa. Ao excluir sua conta, seus dados pessoais são removidos em até 30 dias, exceto os exigidos por obrigação legal.

## 6. Seus Direitos

Você tem o direito de:

- Acessar os dados pessoais que armazenamos sobre você.
- Corrigir informações incorretas diretamente no aplicativo (Perfil → Editar).
- Solicitar a exclusão da sua conta e dados pessoais.
- Configurar ou desativar notificações (Perfil → Configurações de Notificações).

## 7. Crianças

O Entre Sets não é destinado a menores de 13 anos. Não coletamos intencionalmente informações de crianças.

## 8. Alterações nesta Política

Podemos atualizar esta política periodicamente. Alterações significativas serão comunicadas via notificação no aplicativo.

## 9. Contato

Para dúvidas ou solicitações de exclusão de dados:

**HM Labs**
E-mail: contato@hmlabs.com.br
''';

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(loc.privacyPolicy),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => context.pop(),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc.privacyPolicy,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  loc.privacyPolicyUpdated,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onPrimaryContainer.withValues(alpha: 0.7),
                      ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Markdown(
              data: _content,
              padding: const EdgeInsets.all(16),
            ),
          ),
        ],
      ),
    );
  }
}
