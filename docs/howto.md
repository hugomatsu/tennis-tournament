# Guia de Uso do Tennis Tournament App

Este documento descreve o estado atual do aplicativo e instruções de uso.

## O que está funcionando
*   **Autenticação**: Login e Registro de usuários via e-mail/senha.
*   **Torneios**:
    *   Listagem de torneios (Ao vivo, Futuros, Passados).
    *   Detalhes completos: Informações (com mapa do local), Chaves (Brackets) interativas e Calendário de jogos.
    *   Gerenciamento de participantes.
*   **Partidas**:
    *   Detalhes da partida com placar, jogadores e status.
    *   **Localização**: Visualização da foto do local e botão para abrir no Google Maps diretamente do detalhe da partida.
    *   Funcionalidade **"Seguir Partida"**: Usuários podem favoritar partidas e vê-las em sua agenda.
    *   Agendamento e remarcação (Data, Hora, Quadra).
    *   Inserção de resultados (Placar e Vencedor).
*   **Agenda Pessoal**:
    *   Aba "Agenda" exibe partidas em que o usuário joga e partidas que ele segue.
    *   Layout unificado com o calendário do torneio.
*   **Perfil & Assinatura (Premium)**:
    *   Visualização e edição de perfil (Nome, Título, Bio, Categoria, Foto).
    *   **Assinatura Premium**: Tela dedicada para gerenciar assinatura, restaurar compras e cancelar renovação.
*   **Administração**:
    *   **Painel Admin**: Criação de torneios, chaves e gestão de locais.
    *   **Simulação**: Ferramentas de debug para simular partidas e testar fluxos (Botão visível apenas para admins no Perfil).
    *   Geração de chaves (Sorteio Automático ou Manual).
*   **Localização**: Suporte completo para Português (PT-BR) e Inglês (EN).

## O que não está funcionando / Limitações
*   **Notificações Push**: Alertas de início de partida ou mudança de placar ainda não enviam notificações para o celular.
*   **Pagamentos**: Inscrição em torneios é apenas lógica, sem gateway de pagamento real integrado. A tela de assinatura usa "Simulação de Loja".
*   **Chat**: Comunicação direta entre jogadores não implementada.

## Como Criar Torneios
*Funcionalidade restrita a Administradores.*

1.  Acesse seu **Perfil**. Se for Admin, você verá o botão **"Admin Dashboard"**.
2.  No Painel Admin, clique em **"Criar Torneio"**.
3.  Preencha os campos obrigatórios:
    *   **Nome do Torneio**.
    *   **Datas** (Início e Fim).
    *   **Local** (Selecione um local pré-cadastrado em "Gerenciar Locais").
    *   **Categorias** (Ex: Simples Masculino A, Duplas Mistas, etc.).
4.  Clique em **Salvar**. O torneio será criado com status "Upcoming" (Futuro).
5.  Após criar, vá aos detalhes do torneio para adicionar participantes e gerar a chave.

## Perfis de Usuário: O que cada um pode fazer

### 1. Administrador (Admin)
O "Dono da Bola". Tem controle total sobre a organização.
*   **Criar Torneios**: Define tudo sobre o evento.
*   **Gerenciar Chaves**: Gera o chaveamento inicial (pode ordenar manualmente os jogadores).
*   **Agendar Jogos**: Define ou altera data, hora e quadra de qualquer partida. e confirma presença de WO.
*   **Arbitragem**: Insere placares e define o vencedor das partidas e status (Ao Vivo, Finalizado).
*   **Ferramentas de Debug**: Acesso à tela "Simulation & Debug" para popular dados de teste.
*   **Cadastros Básicos**: Gerencia os Locais (clubes/quadras) disponíveis.

### 2. Jogador (Usuário Comum)
Participante ou espectador.
*   **Visualizar**: Acesso total a ver chaves, listas de jogadores, resultados e **Localização no Mapa**.
*   **Seguir**: Pode marcar partidas com uma "Estrela" para acompanhá-las de perto na sua aba "Agenda", e torcer (Cheer).
*   **Jogar**: Vê seus próprios jogos destacados na Agenda e pode **Confirmar Presença** ou **Declinar** jogos agendados.
*   **Perfil**: Pode atualizar sua própria foto e informações pessoais.
*   **Premium**: Pode assinar o plano PRO para remover anúncios (simulado) e apoiar o app.
*   **Restrições**: Não pode alterar placares de terceiros, não pode mudar horários de jogos (apenas solicitar/ver) e não pode criar torneios.
